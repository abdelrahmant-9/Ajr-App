import 'package:flutter/material.dart';
import '../data/azkar_data.dart';
import '../services/azkar_progress_service.dart';
import '../utils/app_colors.dart';
import 'azkar_list_view.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({super.key});

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> with WidgetsBindingObserver {
  Map<AzkarCategory, bool> _progress = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      _progress = {
        for (final cat in AzkarCategory.values)
          cat: AzkarProgressService.isDone(cat.name),
      };
    });
  }

  int get _doneCount => _progress.values.where((v) => v).length;
  int get _totalCount => AzkarCategory.values.length;
  
  // النسبة المئوية بناءً على الأقسام المكتملة
  int get _progressPercent =>
      _totalCount == 0 ? 0 : ((_doneCount / _totalCount) * 100).round();

  void _openCategory(AzkarCategory category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AzkarListView(category: category)),
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black, size: 26),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'الأذكار',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildHeroBanner(),
            const SizedBox(height: 24),
            _buildDailyProgress(),
            const SizedBox(height: 32),
            _buildCategoriesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -25,
            top: 44,
            child: Icon(
              Icons.wb_sunny_rounded,
              size: 150,
              color: AppColors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 24, bottom: 24, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'صباح الخير، لا تنسَ ذكر الله',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ابدأ يومك ببركة الأذكار وطمأنينة القلب',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _openCategory(AzkarCategory.morning),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ابدأ أذكار الصباح',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
    final steps = [
      {'label': 'الفجر', 'cat': AzkarCategory.morning},
      {'label': 'الصباح', 'cat': AzkarCategory.morning},
      {'label': 'المساء', 'cat': AzkarCategory.evening},
      {'label': 'النوم', 'cat': AzkarCategory.sleep},
      {'label': 'الصلاة', 'cat': AzkarCategory.afterPrayer},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_progressPercent% مكتمل',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Text(
                'إنجاز اليوم',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: steps.map((step) {
              final cat = step['cat'] as AzkarCategory;
              final done = _progress[cat] ?? false;
              return Column(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.primary : AppColors.greyLightBlue,
                      boxShadow: [
                        if (!done)
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, color: AppColors.white, size: 22)
                          : const Text(
                              '···',
                              style: TextStyle(color: AppColors.greyBlue, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: AppColors.greyBlue,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 20, bottom: 16),
          child: Text(
            'التصنيفات',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _categoryCard('أذكار الصباح', Icons.wb_sunny_outlined, const Color(0xFFFFF3E0), const Color(0xFFF9A825), AzkarCategory.morning),
            _categoryCard('أذكار المساء', Icons.nights_stay_outlined, const Color(0xFFEDE7F6), const Color(0xFF7E57C2), AzkarCategory.evening),
            _categoryCard('بعد الصلاة', Icons.mosque_outlined, const Color(0xFFE8F5E9), AppColors.green, AzkarCategory.afterPrayer),
            _categoryCard('أذكار النوم', Icons.bed_sharp, const Color(0xFFEDE7F6), const Color(0xFF7E57C2), AzkarCategory.sleep),
          ],
        ),
      ],
    );
  }

  Widget _categoryCard(String title, IconData icon, Color bg, Color iconColor, AzkarCategory cat) {
    return GestureDetector(
      onTap: () => _openCategory(cat),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
