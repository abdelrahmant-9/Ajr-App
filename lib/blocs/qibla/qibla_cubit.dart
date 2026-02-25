import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

import 'qibla_state.dart';

class QiblaCubit extends Cubit<QiblaState> {
  StreamSubscription<QiblahDirection>? _qiblahSubscription;
  StreamSubscription<Position>? _positionSubscription;

  // Kaaba coordinates
  final double kaabaLatitude = 21.422487;
  final double kaabaLongitude = 39.826206;

  QiblaCubit() : super(QiblaInitial());

  Future<void> initQibla() async {
    emit(QiblaLoading());
    final deviceSupport = await FlutterQiblah.androidDeviceSensorSupport();
    if (deviceSupport != true) {
      emit(DeviceNotSupported());
      return;
    }

    await _checkLocationStatus();

    _qiblahSubscription = FlutterQiblah.qiblahStream.listen(
      (qiblah) {
        _updateQiblaDirection(qiblah);
      },
      onError: (e) {
        emit(const QiblaError("حدث خطأ أثناء تحديد اتجاه القبلة"));
      },
    );

    _positionSubscription = Geolocator.getPositionStream().listen(
      (position) {
        final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              kaabaLatitude,
              kaabaLongitude,
            ) /
            1000; // to get it in KM
        if (state is QiblaLoaded) {
          emit(QiblaLoaded((state as QiblaLoaded).qiblahDirection, distance));
        } else {
          // Wait for the first qiblah direction to be available
        }
      },
      onError: (e) {
        // Handle error, maybe show a snackbar or a message
      },
    );
  }

  void _updateQiblaDirection(QiblahDirection qiblah) {
    if (state is QiblaLoaded) {
      emit(QiblaLoaded(qiblah, (state as QiblaLoaded).distance));
    } else {
      emit(QiblaLoaded(qiblah, -1));
    }
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final newStatus = await FlutterQiblah.checkLocationStatus();
      if (newStatus.status == LocationPermission.deniedForever) {
        emit(const QiblaError(
            "يرجى تمكين إذن الموقع من إعدادات التطبيق لاستخدام هذه الميزة."));
      }
    }
  }

  @override
  Future<void> close() {
    _qiblahSubscription?.cancel();
    _positionSubscription?.cancel();
    return super.close();
  }
}
