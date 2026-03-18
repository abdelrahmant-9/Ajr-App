import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ajr/utils/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool _isWeeklySelected = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'الإحصائيات',
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: AppColors.black),
          ),
        ],
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_forward, color: AppColors.black),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 16),

            // ── Streak Card ──
            _buildStreakCard(viewModel),
            const SizedBox(height: 16),

            // ── Summary Cards ──
            _buildSummaryCards(viewModel),
            const SizedBox(height: 16),

            // ── Activity Chart Card ──
            _buildActivityChartCard(viewModel),
            const SizedBox(height: 20),

            // ── Past Days ──
            _buildPastDaysStats(viewModel),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Streak Card
  // ────────────────────────────────────────────────
  Widget _buildStreakCard(HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F8EF7), Color(0xFF6AADFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${viewModel.streak} أيام',
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'سلسلة الأيام الحالية',
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Summary Cards (2 side-by-side)
  // ────────────────────────────────────────────────
  Widget _buildSummaryCards(HomeViewModel viewModel) {
    final total =
    viewModel.counters.values.fold(0, (sum, count) => sum + count);
    final dailyAverage = viewModel.dailyAverage;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'إجمالي التسبيح',
            total.toString(),
            '+12%',
            Colors.green,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSummaryCard(
            'المعدل اليومي',
            dailyAverage.toString(),
            '+5%',
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: AppColors.darkGrey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: AppColors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_upward_rounded, color: changeColor, size: 15),
              const SizedBox(width: 3),
              Text(
                change,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Activity Chart Card (with Daily / Weekly toggle)
  // ────────────────────────────────────────────────
  Widget _buildActivityChartCard(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'النشاط الأسبوعي',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: AppColors.black,
                ),
              ),
              // Toggle: يومي / أسبوعي
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildToggleChip('يومي', !_isWeeklySelected, () {
                      setState(() => _isWeeklySelected = false);
                    }),
                    _buildToggleChip('أسبوعي', _isWeeklySelected, () {
                      setState(() => _isWeeklySelected = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Line Chart
          SizedBox(
            height: 130,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        const days = ['ج', 'س', 'ح', 'ن', 'ث', 'ر', 'خ'];
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = _getTodayIndex() == idx;
                        return Text(
                          days[idx],
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            color: isToday
                                ? AppColors.primary
                                : AppColors.darkGrey,
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartSpots(viewModel),
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        final isToday = _getTodayIndex() == index;
                        return FlDotCirclePainter(
                          radius: isToday ? 5 : 0,
                          color: AppColors.primary,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTodayIndex() {
    final now = DateTime.now();
    const map = {
      DateTime.friday: 0,
      DateTime.saturday: 1,
      DateTime.sunday: 2,
      DateTime.monday: 3,
      DateTime.tuesday: 4,
      DateTime.wednesday: 5,
      DateTime.thursday: 6,
    };
    return map[now.weekday] ?? 0;
  }

  List<FlSpot> _getChartSpots(HomeViewModel viewModel) {
    if (_isWeeklySelected) {
      // أسبوعي — 7 أيام من الأحدث للأقدم
      final weekly = viewModel.weeklyActivity;
      final List<FlSpot> spots = [];
      for (int i = 0; i < 7; i++) {
        spots.add(FlSpot(i.toDouble(), (weekly[i] ?? 0).toDouble()));
      }
      return spots;
    } else {
      // يومي — توزيع ساعات اليوم (محاكاة بـ todayCounters)
      final total = viewModel.todayCounter.toDouble();
      // نوزع الإجمالي على 7 نقاط تمثل فترات اليوم
      return List.generate(7, (i) {
        if (i == _getTodayIndex()) return FlSpot(i.toDouble(), total);
        return FlSpot(i.toDouble(), 0);
      });
    }
  }

  Widget _buildToggleChip(
      String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Past Days List
  // ────────────────────────────────────────────────
  Widget _buildPastDaysStats(HomeViewModel viewModel) {
    final sortedDays = viewModel.dailyTotals.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final recentDays = sortedDays.take(7).toList();

    if (recentDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(recentDays.length, (index) {
        final entry = recentDays[index];
        final date = DateTime.parse(entry.key);
        final count = entry.value;
        final hijriDate = HijriCalendar.fromDate(date);

        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        String? title;
        if (date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day) {
          title = 'أمس';
        }

        return _buildPastDayRow(title, hijriDate, count);
      }),
    );
  }

  Widget _buildPastDayRow(
      String? title, HijriCalendar date, int count) {
    final dateString =
        '${date.hDay} ${date.longMonthName} ${date.hYear}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon + date info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? dateString,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppColors.darkGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'تسبيحة',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.darkGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}