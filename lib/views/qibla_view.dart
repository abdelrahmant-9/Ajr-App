
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../blocs/qibla/qibla_cubit.dart';
import 'calibration_dialog.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaCubit()..initQibla(),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.lightGrey,
          body: SafeArea(child: QiblaBody()),
          bottomNavigationBar: BottomNavBar(),
        ),
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
        if (state is QiblaLoading || state is QiblaInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is QiblaError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 18, color: Colors.red),
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
        return const Center(child: Text("حالة غير معروفة", style: TextStyle(fontFamily: 'Tajawal')));
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
        arrowColor = Colors.green;
        alignmentText = "أنت الآن باتجاه القبلة";
        break;
      case QiblaAlignment.close:
        arrowColor = Colors.lightGreen;
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
          QiblaAppBar(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${widget.compassHeading.toStringAsFixed(0)}°",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCardinalDirection(widget.compassHeading),
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 20,
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
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 20,
                            ),
                          ],
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
                          size: 200,
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
                        top: 25,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: arrowColor, // Match arrow color
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.mosque, color: Colors.white, size: 22),
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
                const SizedBox(height: 10),
                const Text(
                  "يرجى وضع الهاتف بشكل مسطح لأفضل دقة",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          LocationCard(distance: widget.distance),
          const SizedBox(height: 20),
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

class QiblaAppBar extends StatelessWidget {
  const QiblaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.all_inclusive, color: AppColors.darkGrey, size: 28),
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => CalibrationDialog(
                onDone: () {
                  context.read<QiblaCubit>().resetCompass();
                },
              ),
            );
          },
        ),
        const Text(
          "اتجاه القبلة",
          style: TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppColors.darkGrey, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
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
                  color: AppColors.grey,
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (distance > 0) ? "${distance.toStringAsFixed(0)} كم" : "...",
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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0, // Assuming this is the 'home' or 'main' screen in the context of the bottom nav
          selectedLabelStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Tajawal'),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              label: "الأذكار",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: "الإحصائيات",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "الإعدادات",
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            }
            // Handle other taps if necessary
          },
        ),
      ),
    );
  }
}
