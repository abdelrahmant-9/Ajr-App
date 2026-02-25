import 'package:equatable/equatable.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

abstract class QiblaState extends Equatable {
  const QiblaState();

  @override
  List<Object?> get props => [];
}

class QiblaInitial extends QiblaState {}

class QiblaLoading extends QiblaState {}

class QiblaLoaded extends QiblaState {
  final QiblahDirection qiblahDirection;
  final double distance;

  const QiblaLoaded(this.qiblahDirection, this.distance);

  @override
  List<Object?> get props => [qiblahDirection, distance];
}

class QiblaError extends QiblaState {
  final String message;

  const QiblaError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceNotSupported extends QiblaState {}
