import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../utils/app_colors.dart';
import '../blocs/qibla/qibla_cubit.dart';
import '../blocs/qibla/qibla_state.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaCubit()..initQibla(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: _buildAppBar(context),
          body: const QiblaBody(),
          bottomNavigationBar: _bottomNavBar(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        "اتجاه القبلة",
        style: TextStyle(
          color: AppColors.black,
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: AppColors.black),
          onPressed: () {},
        ),
      ],
      centerTitle: true,
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
        if (state is DeviceNotSupported) {
          return const Center(
            child: Text(
              "عذرًا، جهازك لا يدعم المستشعرات اللازمة لتحديد اتجاه القبلة.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
            ),
          );
        }
        if (state is QiblaError) {
          return Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, color: Colors.red),
            ),
          );
        }
        if (state is QiblaLoaded) {
          return QiblahCompass(
            qiblahDirection: state.qiblahDirection,
            distance: state.distance,
          );
        }
        return const Center(child: Text("حالة غير معروفة"));
      },
    );
  }
}

class QiblahCompass extends StatelessWidget {
  final QiblahDirection qiblahDirection;
  final double distance;

  const QiblahCompass({super.key, required this.qiblahDirection, required this.distance});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${(qiblahDirection.direction % 360).toStringAsFixed(0)}°",
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 30),
            _buildQiblaStatus(qiblahDirection),
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
            const SizedBox(height: 30),
            _buildLocationCard(distance),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaStatus(QiblahDirection qiblahDirection) {
    final isAligned = qiblahDirection.offset.abs() < 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isAligned ? AppColors.primaryVeryLight.withOpacity(0.7) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isAligned ? Icons.check_circle_outline : Icons.explore_outlined, color: isAligned ? AppColors.primary : AppColors.darkGrey),
          const SizedBox(width: 8),
          Text(
            isAligned ? "أنت الآن باتجاه القبلة" : "قم بتدوير الهاتف",
            style: TextStyle(
              color: isAligned ? AppColors.primary : AppColors.darkGrey,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(double distance) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 40),
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
                  ),
                ),
                Text(
                  (distance > 0) ? "${distance.toStringAsFixed(0)} كم" : "جاري الحساب..",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _bottomNavBar(BuildContext context) {
  return BottomNavigationBar(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.grey,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    currentIndex: 0,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "الرئيسية",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.menu_book),
        label: "الأذكار",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: "الإحصائيات",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "الإعدادات",
      ),
    ],
    onTap: (index) {
      if (index == 0) {
        Navigator.pop(context);
      }
    },
  );
}
