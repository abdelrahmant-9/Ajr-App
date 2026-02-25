
import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:vibration/vibration.dart';

enum QiblaAlignment { aligned, close, far }

class QiblaCubit extends Cubit<QiblaState> {
  QiblaCubit() : super(QiblaInitial());

  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _hasVibrated = false;

  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  void initQibla() async {
    emit(QiblaLoading());
    try {
      final locationStatus = await Geolocator.checkPermission();
      if (locationStatus == LocationPermission.denied ||
          locationStatus == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final qiblaDirection = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _kaabaLat,
        _kaabaLng,
      );
      final distanceInKm = distanceInMeters / 1000;

      _compassSubscription = FlutterCompass.events?.listen((event) {
        final compassHeading = event.heading ?? 0;
        final normalizedHeading = (compassHeading % 360 + 360) % 360;

        final diff = _calculateAngleDifference(qiblaDirection, normalizedHeading);
        final alignment = _getAlignment(diff);

        if (alignment == QiblaAlignment.aligned) {
          if (!_hasVibrated) {
            Vibration.hasVibrator().then((hasVibrator) {
              if (hasVibrator ?? false) {
                Vibration.vibrate(duration: 300);
                _hasVibrated = true;
              }
            });
          }
        } else {
          _hasVibrated = false;
        }

        emit(QiblaLoaded(
          qiblaDirection: qiblaDirection,
          compassHeading: normalizedHeading,
          distance: distanceInKm,
          alignment: alignment,
        ));
      });
    } catch (e) {
      emit(QiblaError(e.toString()));
    }
  }

  double _calculateQiblaDirection(double userLat, double userLng) {
    final double lat1 = vm.radians(userLat);
    final double lon1 = vm.radians(userLng);
    final double lat2 = vm.radians(_kaabaLat);
    final double lon2 = vm.radians(_kaabaLng);

    final double dLon = lon2 - lon1;
    final double y = sin(dLon);
    final double x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLon);

    double bearing = atan2(y, x);
    bearing = vm.degrees(bearing);

    return (bearing + 360) % 360;
  }

  double _calculateAngleDifference(double a, double b) {
    double diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  QiblaAlignment _getAlignment(double diff) {
    if (diff <= 3) {
      return QiblaAlignment.aligned;
    } else if (diff <= 6) {
      return QiblaAlignment.close;
    } else {
      return QiblaAlignment.far;
    }
  }

  @override
  Future<void> close() {
    _compassSubscription?.cancel();
    return super.close();
  }
}

abstract class QiblaState extends Equatable {
  const QiblaState();

  @override
  List<Object> get props => [];
}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaLoaded extends QiblaState {
  final double qiblaDirection;
  final double compassHeading;
  final double distance;
  final QiblaAlignment alignment;

  const QiblaLoaded({
    required this.qiblaDirection,
    required this.compassHeading,
    required this.distance,
    required this.alignment,
  });

  @override
  List<Object> get props => [qiblaDirection, compassHeading, distance, alignment];
}

class QiblaError extends QiblaState {
  final String message;

  const QiblaError(this.message);

  @override
  List<Object> get props => [message];
}
