import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tasbeeh_app/views/qibla_view.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).init();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut, reverseCurve: Curves.easeIn),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _toArabicNumbers(String number) {
    return number.replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢').replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥').replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨').replaceAll('9', '٩');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        if (!vm.isLoading && vm.counter == vm.goal && _previousCount < vm.goal && vm.goal != 0) {
          _confettiController.play();
        }
        if (!vm.isLoading) {
          _previousCount = vm.counter;
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Skeletonizer(
                  enabled: vm.isLoading,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
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
                            _toArabicNumbers(vm.isLoading ? "0" : vm.counter.toString()),
                            key: ValueKey<int>(vm.isLoading ? 0 : vm.counter),
                            style: const TextStyle(
                              fontSize: 80,
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                        ),

                        /// Zekr Title (Button)
                        GestureDetector(
                          onTap: () => _showZekrPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryVeryLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(opacity: animation, child: child),
                              child: Text(
                                vm.currentZekr,
                                key: ValueKey(vm.currentZekr),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_toArabicNumbers(vm.isLoading ? "0" : vm.counter.toString())} / ${_toArabicNumbers(vm.goal.toString())}',
                                    style: TextStyle(
                                      color: (!vm.isLoading && vm.counter >= vm.goal && vm.goal != 0) ? AppColors.primary : AppColors.darkGrey,
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
                        Skeleton.leaf(
                          child: Stack(
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
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildChip("السجل", Icons.history, () {}),
                            const SizedBox(width: 20),
                            _buildChip("تصفير", Icons.refresh, !vm.isLoading && vm.counter == 0 ? null : () {
                              _showResetConfirmationDialog(context, vm);
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.0,
                    numberOfParticles: 100,
                    gravity: 0.1,
                    shouldLoop: false,
                    colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showZekrPicker(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    final searchController = TextEditingController();
    final addZekrController = TextEditingController();
    List<String> filtered = List.from(viewModel.azkar);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            void _addZekr() {
              final value = addZekrController.text.trim();
              if (value.isNotEmpty) {
                if (viewModel.azkar.any((e) => e.toLowerCase() == value.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("الذكر موجود بالفعل", style: TextStyle(fontFamily: 'Tajawal')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                viewModel.addCustomZekr(value);
                addZekrController.clear();
                searchController.clear();
                setState(() {
                  filtered = List.from(viewModel.azkar);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("تم إضافة الذكر بنجاح", style: TextStyle(fontFamily: 'Tajawal')),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                );
              }
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search
                      TextField(
                        controller: searchController,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: "ابحث عن ذكر...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.lightGrey,
                        ),
                        onChanged: (value) {
                          setState(() {
                            filtered = viewModel.azkar
                                .where((e) => e.toLowerCase().contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Add custom
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: addZekrController,
                              textAlign: TextAlign.right,
                              decoration: const InputDecoration(
                                hintText: "إضافة ذكر مخصص",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.lightGrey,
                              ),
                              onSubmitted: (_) => _addZekr(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: AppColors.primary),
                              onPressed: _addZekr,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // List
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            viewModel.reorderZekr(oldIndex, newIndex);
                            filtered = List.from(viewModel.azkar);
                          });
                        },
                        children: filtered.map((zekr) {
                          final isSelected = zekr == viewModel.currentZekr;
                          return Dismissible(
                            key: Key(zekr),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              setState(() {
                                viewModel.removeZekr(zekr);
                                filtered.remove(zekr);
                              });
                            },
                            child: ListTile(
                              title: Text(
                                zekr,
                                style: TextStyle(
                                  color: isSelected ? AppColors.primary : AppColors.black,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                                  : const Icon(Icons.radio_button_unchecked),
                              onTap: () async {
                                if (await Vibration.hasVibrator() ?? false) {
                                  Vibration.vibrate(duration: 50);
                                }
                                viewModel.changeZekr(zekr);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
}
