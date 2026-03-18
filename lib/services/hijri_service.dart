import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const int _kCacheVersion = 4; // Cache version bumped to force refresh

class HijriService extends ChangeNotifier {
  final _box = Hive.box('hijriCache');
  String _currentCountryCode = 'SA';
  Map<String, dynamic> _currentCalendar = {};

  String get currentCountryCode => _currentCountryCode;

  Future<void> init() async {
    // Invalidate cache if version is outdated
    final cachedVersion = _box.get('cacheVersion');
    if (cachedVersion == null || cachedVersion != _kCacheVersion) {
      await _box.clear();
      await _box.put('cacheVersion', _kCacheVersion);
      log("Hijri cache cleared and version updated to $_kCacheVersion");
    }

    // Always detect country on startup
    final detectedCountry = await _detectCountryFromLocation();
    await setCountry(detectedCountry, isInit: true);
  }

  Future<void> setCountry(String countryCode, {bool isInit = false}) async {
    if (!isInit && _currentCountryCode == countryCode) return;

    _currentCountryCode = countryCode;
    await _box.put('userSelectedCountry', countryCode);

    await _loadCalendar();
    notifyListeners();
  }

  Future<void> refreshCountry() async {
    final detectedCountry = await _detectCountryFromLocation();
    await setCountry(detectedCountry);
  }

  Future<String> _detectCountryFromLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'SA';
      }

      if (permission == LocationPermission.deniedForever) return 'SA';

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      return placemarks.first.isoCountryCode ?? 'SA';
    } catch (e) {
      log("Country detection failed: $e");
      return 'SA';
    }
  }

  Future<void> _loadCalendar() async {
    // Load from cache if available
    if (_box.containsKey(_currentCountryCode)) {
      _currentCalendar = Map<String, dynamic>.from(_box.get(_currentCountryCode));
      log("Loaded calendar for $_currentCountryCode from cache.");
      return;
    }

    // Otherwise, fetch from API
    await _fetchAndCacheCalendar();
  }

  HijriCalendar getHijriDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final data = _currentCalendar[key];

    if (data != null && data is Map && data.containsKey('hDay')) {
      return HijriCalendar()
        ..hYear = data['hYear']
        ..hMonth = data['hMonth']
        ..hDay = data['hDay'];
    }

    // Fallback: If the date is not in our API-fetched calendar,
    // use the local conversion and apply the standard adjustment.
    final adjustedDate = date.subtract(const Duration(days: 1));
    return HijriCalendar.fromDate(adjustedDate); // Adjust by -1 day
  }

  Future<void> _fetchAndCacheCalendar() async {
    Map<String, dynamic> yearCalendar = {};
    try {
      for (int month = 1; month <= 12; month++) {
        // Fetch raw data without API adjustment
        final url = Uri.parse('http://api.aladhan.com/v1/gToHCalendar/$month/${DateTime.now().year}?country=$_currentCountryCode');
        final response = await http.get(url, headers: {'Accept': 'application/json'});

        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'];
          for (var dayData in data) {
            final gregorian = dayData['gregorian'];
            final hijriDataFromApi = dayData['hijri'];

            final String apiDate = gregorian['date'];
            final List<String> dateParts = apiDate.split('-');
            if (dateParts.length != 3) continue;

            final dateKey = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

            // Create a HijriCalendar object from the API data
            var hijriCal = HijriCalendar()
              ..hYear = int.parse(hijriDataFromApi['year'])
              ..hMonth = hijriDataFromApi['month']['number']
              ..hDay = int.parse(hijriDataFromApi['day']);

            // Apply the adjustment manually inside the app
            final converter = HijriCalendar();
            final gregorianEquivalent = converter.hijriToGregorian(hijriCal.hYear, hijriCal.hMonth, hijriCal.hDay);
            final adjustedGregorian = gregorianEquivalent.subtract(const Duration(days: 1));
            hijriCal = HijriCalendar.fromDate(adjustedGregorian);

            // Store the manually adjusted date
            yearCalendar[dateKey] = {
              'hDay': hijriCal.hDay,
              'hMonth': hijriCal.hMonth,
              'hYear': hijriCal.hYear,
              'longMonthName': hijriCal.longMonthName, // Use the name from the adjusted calendar
              'method': _currentCountryCode
            };
          }
        } else {
          log("Failed to load Hijri data for month $month");
        }
      }
      if (yearCalendar.isNotEmpty) {
        await _box.put(_currentCountryCode, yearCalendar);
        _currentCalendar = yearCalendar;
        log("Successfully cached Hijri calendar for $_currentCountryCode with manual adjustment");
      }
    } catch (e) {
      log("Error fetching/caching Hijri Calendar: $e");
    }
  }
}