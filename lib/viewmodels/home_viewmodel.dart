import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/repository/ajr_repository.dart';
import '../models/ajr_model.dart';

class HomeViewModel extends ChangeNotifier {
  final repository = AjrRepository();

  Map<String, int> _counters = {};
  Map<String, int> _todayCounters = {};
  String _currentZekr = "سبحان الله";
  DateTime _lastResetDate = DateTime.now();
  List<DateTime> _usageDates = [];
  Map<String, int> _dailyTotals = {};

  bool _isLoading = true;

  // Getters
  int get counter => _counters[_currentZekr] ?? 0;
  int get todayCounter => _todayCounters[_currentZekr] ?? 0;
  String get currentZekr => _currentZekr;
  Map<String, int> get counters => _counters;
  Map<String, int> get todayCounters => _todayCounters;
  Map<String, int> get dailyTotals => _dailyTotals;
  double get progress => isLoading ? 0.0 : (todayCounter / goal).clamp(0.0, 1.0);
  bool get isLoading => _isLoading;

  // Stats Getters
  int get streak {
    if (_usageDates.isEmpty) return 0;
    _usageDates.sort((a, b) => b.compareTo(a));
    int currentStreak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    if (_usageDates.first.year == currentDate.year &&
        _usageDates.first.month == currentDate.month &&
        _usageDates.first.day == currentDate.day) {
      currentStreak++;
    } else if (_usageDates.first.year == currentDate.subtract(const Duration(days: 1)).year &&
        _usageDates.first.month == currentDate.subtract(const Duration(days: 1)).month &&
        _usageDates.first.day == currentDate.subtract(const Duration(days: 1)).day) {
      currentStreak++;
    } else {
      return 0;
    }

    for (int i = 0; i < _usageDates.length - 1; i++) {
      Duration diff = _usageDates[i].difference(_usageDates[i + 1]);
      if (diff.inDays == 1) {
        currentStreak++;
      } else if (diff.inDays > 1) {
        break;
      }
    }
    return currentStreak;
  }

  int get dailyAverage {
    if (_usageDates.isEmpty) return 0;
    final totalTasbeeh = _counters.values.fold(0, (sum, item) => sum + item);
    final uniqueDays =
        _usageDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().length;
    return uniqueDays > 0 ? (totalTasbeeh / uniqueDays).round() : 0;
  }

  Map<int, double> get weeklyActivity {
    final Map<int, double> data = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // تحديد index اليوم الحالي في الأسبوع (يبدأ من الجمعة = 0)
    // DateTime.weekday: Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7
    int todayIndex;
    switch (now.weekday) {
      case DateTime.friday:
        todayIndex = 0;
        break;
      case DateTime.saturday:
        todayIndex = 1;
        break;
      case DateTime.sunday:
        todayIndex = 2;
        break;
      case DateTime.monday:
        todayIndex = 3;
        break;
      case DateTime.tuesday:
        todayIndex = 4;
        break;
      case DateTime.wednesday:
        todayIndex = 5;
        break;
      case DateTime.thursday:
        todayIndex = 6;
        break;
      default:
        todayIndex = 0;
    }

    // أول يوم في الأسبوع (الجمعة الماضية أو اليوم لو جمعة)
    final DateTime startOfWeek = today.subtract(Duration(days: todayIndex));

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateKey = date.toIso8601String().substring(0, 10);

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        // اليوم الحالي — من _todayCounters
        data[i] = (_todayCounters.values.fold(0, (sum, val) => sum + val)).toDouble();
      } else {
        // أيام سابقة — من _dailyTotals
        data[i] = (_dailyTotals[dateKey] ?? 0).toDouble();
      }
    }

    return data;
  }

  final int goal = 100;

  List<String> _azkar = [];
  List<String> get azkar => _azkar;

  HomeViewModel() {
    _loadAzkar();
  }

  void _saveModel() {
    repository.save(
      AjrModel(
        counters: _counters,
        currentZekr: _currentZekr,
        lastUpdated: DateTime.now(),
        todayCounters: _todayCounters,
        lastResetDate: _lastResetDate,
        usageDates: _usageDates,
        dailyTotals: _dailyTotals,
      ),
    );
  }

  void _loadAzkar() {
    final box = Hive.box('ajrBox');
    _azkar = box.get('azkar', defaultValue: [
      "سبحان الله",
      "الحمد لله",
      "الله أكبر",
      "لا إله إلا الله",
      "استغفر الله",
    ]).cast<String>();
  }

  void _saveAzkar() {
    Hive.box('ajrBox').put('azkar', _azkar);
    notifyListeners();
  }

  void _resetTodayCountersIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset =
    DateTime(_lastResetDate.year, _lastResetDate.month, _lastResetDate.day);

    if (today.isAfter(lastReset)) {
      final yesterdayTotal =
      _todayCounters.values.fold(0, (sum, item) => sum + item);
      if (yesterdayTotal > 0) {
        final yesterdayKey = lastReset.toIso8601String().substring(0, 10);
        _dailyTotals[yesterdayKey] = yesterdayTotal;
      }

      _todayCounters = {};
      _lastResetDate = now;
      for (final zekr in _azkar) {
        _todayCounters.putIfAbsent(zekr, () => 0);
      }
    }
  }

  void _trackUsage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!_usageDates.any((date) =>
    date.year == today.year &&
        date.month == today.month &&
        date.day == today.day)) {
      _usageDates.add(today);
    }
  }

  Future<void> init() async {
    _isLoading = true;
    try {
      final AjrModel model = await repository.get();
      _counters = model.counters;
      _currentZekr = model.currentZekr;
      _todayCounters = model.todayCounters;
      _lastResetDate = model.lastResetDate;
      _usageDates = model.usageDates;
      _dailyTotals = model.dailyTotals;

      _resetTodayCountersIfNeeded();
      _trackUsage();
    } catch (e) {
      _counters = {};
      _todayCounters = {};
      _currentZekr = _azkar.isNotEmpty ? _azkar.first : "سبحان الله";
      _lastResetDate = DateTime.now();
      _usageDates = [];
      _dailyTotals = {};
    }

    for (final zekr in _azkar) {
      _counters.putIfAbsent(zekr, () => 0);
      _todayCounters.putIfAbsent(zekr, () => 0);
    }
    _counters.putIfAbsent(_currentZekr, () => 0);
    _todayCounters.putIfAbsent(_currentZekr, () => 0);

    _isLoading = false;
    notifyListeners();
  }

  void changeZekr(String newZekr) {
    if (_currentZekr == newZekr) return;
    _currentZekr = newZekr;
    _counters.putIfAbsent(newZekr, () => 0);
    _todayCounters.putIfAbsent(newZekr, () => 0);
    notifyListeners();
    _saveModel();
  }

  void addCustomZekr(String zekr) {
    if (zekr.trim().isNotEmpty && !_azkar.contains(zekr.trim())) {
      final newZekr = zekr.trim();
      _azkar.add(newZekr);
      _counters.putIfAbsent(newZekr, () => 0);
      _todayCounters.putIfAbsent(newZekr, () => 0);
      _saveAzkar();
      _saveModel();
    }
  }

  void removeZekr(String zekr) {
    _azkar.remove(zekr);
    _counters.remove(zekr);
    _todayCounters.remove(zekr);
    if (_currentZekr == zekr) {
      _currentZekr = _azkar.isNotEmpty ? _azkar.first : "سبحان الله";
    }
    _saveAzkar();
    _saveModel();
  }

  void reorderZekr(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _azkar.removeAt(oldIndex);
    _azkar.insert(newIndex, item);
    _saveAzkar();
  }

  void increment() {
    _counters[_currentZekr] = counter + 1;
    _todayCounters[_currentZekr] = todayCounter + 1;
    _trackUsage();
    notifyListeners();
    _saveModel();
  }

  void reset() {
    _counters[_currentZekr] = 0;
    _todayCounters[_currentZekr] = 0;
    notifyListeners();
    _saveModel();
  }
}