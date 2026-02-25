
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../utils/app_colors.dart';
import '../blocs/qibla/qibla_cubit.dart';
import 'calibration_dialog.dart';

// Helper function to convert numbers to Arabic numerals
String _toArabicNumbers(String number) {
  return number
      .replaceAll('0', '٠')
      .replaceAll('1', '١')
      .replaceAll('2', '٢')
      .replaceAll('3', '٣')
      .replaceAll('4', '٤')
      .replaceAll('5', '٥')
      .replaceAll('6', '٦')
      .replaceAll('7', '٧')
      .replaceAll('8', '٨')
      .replaceAll('9', '٩');
}

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaCubit()..initQibla(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            backgroundColor: AppColors.lightGrey,
            appBar: AppBar(
              backgroundColor: AppColors.lightGrey,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false, // We'll handle the leading widget manually
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.darkGrey, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                "اتجاه القبلة",
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              actions: [
                Builder(
                  builder: (context) { // Use Builder to get the context that contains the Cubit
                    return IconButton(
                      icon: const Icon(Icons.all_inclusive_outlined, color: AppColors.darkGrey, size: 28),
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                          barrierColor: Colors.black.withOpacity(0.5),
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (context, animation1, animation2) => const SizedBox(),
                          transitionBuilder: (dialogContext, animation1, animation2, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation1,
                              curve: Curves.easeOut,
                              reverseCurve: Curves.easeIn,
                            );
                            return ScaleTransition(
                              scale: curvedAnimation,
                              child: CalibrationDialog(
                                onDone: () {
                                  context.read<QiblaCubit>().resetCompass();
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                ),
              ],
            ),
            body: const SafeArea(child: QiblaBody())),
      ),
    );
  }
}

class QiblaBody extends StatelessWidget {
  const QiblaBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QiblaCubit, QiblaState>(
      builder: (context, state) {
        final isLoading = state is QiblaLoading || state is QiblaInitial;
        return Skeletonizer(
          enabled: isLoading,
          child: Builder(builder: (context) {
            if (state is QiblaError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Tajawal', fontSize: 18, color: Colors.red),
                  ),
                ),
              );
            }
            if (state is QiblaLoaded) {
              return QiblahCompass(
                qiblaDirection: state.qiblaDirection,
                compassHeading: state.compassHeading,
                distance: state.distance,
                alignment: state.alignment,
              );
            }
            // Render a skeleton version of QiblahCompass for the loading state
            return const QiblahCompass(
              qiblaDirection: 0,
              compassHeading: 0,
              distance: 0,
              alignment: QiblaAlignment.far,
            );
          }),
        );
      },
    );
  }
}

class QiblahCompass extends StatefulWidget {
  final double qiblaDirection;
  final double compassHeading;
  final double distance;
  final QiblaAlignment alignment;

  const QiblahCompass({
    super.key,
    required this.qiblaDirection,
    required this.compassHeading,
    required this.distance,
    required this.alignment,
  });

  @override
  State<QiblahCompass> createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _begin = 0;
  double _end = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _end = _calculateAngle();
    _animation = Tween<double>(begin: _begin, end: _end).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant QiblahCompass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compassHeading != widget.compassHeading || oldWidget.qiblaDirection != widget.qiblaDirection) {
      _begin = _animation.value;
      _end = _calculateAngle();

      // Shortest path logic
      if ((_end - _begin).abs() > pi) {
        if (_end > _begin) {
          _begin += 2 * pi;
        } else {
          _begin -= 2 * pi;
        }
      }

      _animation = Tween<double>(begin: _begin, end: _end).animate(_controller);
      _controller.forward(from: 0);
    }
  }

  double _calculateAngle() {
    return (widget.qiblaDirection - widget.compassHeading) * (pi / 180);
  }

  String _getCardinalDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) {
      return 'الشمال';
    } else if (heading >= 22.5 && heading < 67.5) {
      return 'الشمال الشرقي';
    } else if (heading >= 67.5 && heading < 112.5) {
      return 'الشرق';
    } else if (heading >= 112.5 && heading < 157.5) {
      return 'الجنوب الشرقي';
    } else if (heading >= 157.5 && heading < 202.5) {
      return 'الجنوب';
    } else if (heading >= 202.5 && heading < 247.5) {
      return 'الجنوب الغربي';
    } else if (heading >= 247.5 && heading < 292.5) {
      return 'الغرب';
    } else { // 292.5 to 337.5
      return 'الشمال الغربي';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color arrowColor;
    final String alignmentText;

    switch (widget.alignment) {
      case QiblaAlignment.aligned:
        arrowColor = AppColors.emaraldgreen;
        alignmentText = "أنت الآن باتجاه القبلة";
        break;
      case QiblaAlignment.close:
        arrowColor = AppColors.lightgreen;
        alignmentText = "اقتربت من اتجاه القبلة";
        break;
      case QiblaAlignment.far:
      default:
        arrowColor = AppColors.primary;
        alignmentText = "قم بتدوير الهاتف لمواءمة السهم";
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_toArabicNumbers(widget.compassHeading.toStringAsFixed(0))}°",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 55,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  _getCardinalDirection(widget.compassHeading),
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 300,
                  width: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass background
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.lightGrey,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                        ),
                      ),
                      // The rotating arrow
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _animation.value,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.navigation_rounded,
                          size: 180,
                          color: arrowColor,
                        ),
                      ),
                      // Center circle of the compass
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: arrowColor, // Match the arrow color
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Kaaba icon at the top
                      Positioned(
                        top: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Skeleton.leaf(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: arrowColor, // Match arrow color
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Skeleton.leaf(
                              child: Container(
                                width: 3,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: arrowColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  alignmentText,
                  style: TextStyle(
                    color: arrowColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "يرجى وضع الهاتف بشكل مسطح لأفضل دقة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          LocationCard(distance: widget.distance),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LocationCard extends StatelessWidget {
  final double distance;

  const LocationCard({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 30),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مكة المكرمة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  "المملكة العربية السعودية",
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "المسافة",
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (distance > 0) ? "${_toArabicNumbers(distance.toStringAsFixed(0))} كم" : "...",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
