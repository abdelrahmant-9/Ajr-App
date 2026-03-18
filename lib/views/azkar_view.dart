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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeroBanner(),
                    const SizedBox(height: 14),
                    _buildDailyProgress(),
                    const SizedBox(height: 20),
                    _buildCategoriesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'الأذكار',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          // السهم على اليمين دايماً
          Positioned(
            right: 0,
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFBBBBCC),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F8EF7), Color(0xFF6AADFF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            left: -24,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x18FFFFFF),
              ),
            ),
          ),
          // المحتوى محاذي لليمين
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'صباح الخير، لا تنسَ ذكر الله',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'ابدأ يومك ببركة الأذكار وطمأنينة القلب',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  color: Color(0xCCFFFFFF),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _openCategory(AzkarCategory.morning),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'ابدأ أذكار الصباح',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F8EF7),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
    // الترتيب: الفجر على اليمين، الصلاة على اليسار
    final steps = [
      {'label': 'الفجر', 'cat': AzkarCategory.morning},
      {'label': 'الصباح', 'cat': AzkarCategory.morning},
      {'label': 'المساء', 'cat': AzkarCategory.evening},
      {'label': 'النوم', 'cat': AzkarCategory.sleep},
      {'label': 'الصلاة', 'cat': AzkarCategory.afterPrayer},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // العنوان على اليمين، البادج على اليسار
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_progressPercent% مكتمل',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F8EF7),
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'إنجاز اليوم',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // الخطوات: الفجر على اليمين
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: steps.map((step) {
              final cat = step['cat'] as AzkarCategory;
              final done = _progress[cat] ?? false;
              return Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? const Color(0xFF4F8EF7)
                          : const Color(0xFFEEF4FF),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : const Text(
                        '···',
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: Color(0xFF888888),
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
    final gridItems = [
      _CategoryGridItem(
        title: 'أذكار الصباح',
        icon: Icons.wb_sunny_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFF9A825),
        category: AzkarCategory.morning,
        done: _progress[AzkarCategory.morning] ?? false,
      ),
      _CategoryGridItem(
        title: 'أذكار المساء',
        icon: Icons.nights_stay_outlined,
        iconBg: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF7E57C2),
        category: AzkarCategory.evening,
        done: _progress[AzkarCategory.evening] ?? false,
      ),
      _CategoryGridItem(
        title: 'بعد الصلاة',
        icon: Icons.mosque_outlined,
        iconBg: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF43A047),
        category: AzkarCategory.afterPrayer,
        done: _progress[AzkarCategory.afterPrayer] ?? false,
      ),
      _CategoryGridItem(
        title: 'أذكار النوم',
        icon: Icons.bedtime_outlined,
        iconBg: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF7E57C2),
        category: AzkarCategory.sleep,
        done: _progress[AzkarCategory.sleep] ?? false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 20, bottom: 14),
          child: Text(
            'التصنيفات',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: gridItems.map((item) {
            return GestureDetector(
              onTap: () => _openCategory(item.category),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                child: Column(
                  // الأيقونة في أعلى اليمين، النص في أسفل اليمين
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.icon,
                                color: item.iconColor, size: 24),
                          ),
                          if (item.done)
                            Positioned(
                              top: -4,
                              left: -4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF43A047),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 11),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryGridItem {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final AzkarCategory category;
  final bool done;

  const _CategoryGridItem({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.category,
    required this.done,
  });
}