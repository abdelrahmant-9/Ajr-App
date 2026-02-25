
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tasbeeh_app/views/qibla_view.dart';
import '../utils/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  int _previousCount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut, reverseCurve: Curves.easeIn),
    );

    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _toArabicNumbers(String number) {
    return number.replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢').replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥').replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨').replaceAll('9', '٩');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    if (vm.count == vm.goal && _previousCount < vm.goal && vm.goal != 0) {
      _confettiController.play();
    }
    _previousCount = vm.count;

    return Skeletonizer(
      enabled: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: _bottomNavBar(),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// Top Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: IconButton(
                            icon: const Icon(Icons.explore_outlined, color: AppColors.primary),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const QiblaView()),
                              );
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: IconButton(
                            icon: const Icon(Icons.person_outline, color: AppColors.primary),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// Counter
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _toArabicNumbers(vm.count.toString()),
                        key: ValueKey<int>(vm.count),
                        style: const TextStyle(
                          fontSize: 80,
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                    ),

                    /// Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryVeryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "سبحان الله",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_toArabicNumbers(vm.count.toString())} / ${_toArabicNumbers(vm.goal.toString())}',
                                style: TextStyle(
                                  color: (vm.count >= vm.goal && vm.goal != 0) ? AppColors.primary : AppColors.darkGrey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              const Text(
                                "الهدف اليومي",
                                style: TextStyle(color: AppColors.darkGrey, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Tajawal'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: LinearProgressIndicator(
                              value: vm.progress,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(10),
                              backgroundColor: AppColors.lightGrey,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Big Circular Button
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.05),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) {
                            _animationController.reverse();
                            vm.increment();
                          },
                          onTapCancel: () => _animationController.reverse(),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3 * _animationController.value),
                                        blurRadius: 30 * _animationController.value,
                                        spreadRadius: 15 * _animationController.value,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app_outlined, color: AppColors.white, size: 50),
                                SizedBox(height: 10),
                                Text(
                                  "اضغط هنا",
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChip("السجل", Icons.history, () {}),
                        const SizedBox(width: 20),
                        _buildChip("تصفير", Icons.refresh, vm.count == 0 ? null : () {
                          _showResetConfirmationDialog(context, vm);
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0,
                  numberOfParticles: 100,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, HomeViewModel vm) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: const Text('تصفير العداد',
                style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, color: AppColors.black)),
            content: const Text('هل أنت متأكد من تصفير العداد؟',
                style: TextStyle(fontFamily: 'Tajawal', color: AppColors.black)),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('إلغاء',
                    style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppColors.black,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(buildContext).pop();
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('تصفير العداد',
                    style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppColors.white,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  vm.reset();
                  Navigator.of(buildContext).pop();
                },
              ),
            ],
            actionsAlignment: MainAxisAlignment.spaceBetween,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildChip(String label, IconData icon, VoidCallback? onPressed) {
    bool isEnabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Chip(
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal', color: AppColors.black)),
          avatar: Icon(icon, color: AppColors.darkGrey),
          backgroundColor: AppColors.lightGrey,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
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
    );
  }
}
