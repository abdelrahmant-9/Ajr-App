import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

class QiblaViewModel extends ChangeNotifier {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  StreamSubscription<QiblahDirection>? _qiblahSubscription;
  StreamSubscription<Position>? _positionSubscription;

  QiblahDirection? _qiblahDirection;
  QiblahDirection? get qiblahDirection => _qiblahDirection;

  double _distance = -1;
  double get distance => _distance;

  Future<bool?> get deviceSupport => _deviceSupport;

  // Kaaba coordinates
  final double kaabaLatitude = 21.422487;
  final double kaabaLongitude = 39.826206;

  QiblaViewModel() {
    _checkLocationStatus();
    _qiblahSubscription = FlutterQiblah.qiblahStream.listen((qiblah) {
      _qiblahDirection = qiblah;
      notifyListeners();
    }, onError: (e) {
      _qiblahDirection = null;
      notifyListeners();
    });

    _positionSubscription = Geolocator.getPositionStream().listen((position) {
      _distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            kaabaLatitude,
            kaabaLongitude,
          ) / 1000; // to get it in KM
      notifyListeners();
    }, onError: (e) {
      // Handle error
      _distance = -1;
      notifyListeners();
    });
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
    }
  }

  @override
  void dispose() {
    _qiblahSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
