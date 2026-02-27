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

  String _toArabicNumbers(String number) {
    return number.replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢').replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥').replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨').replaceAll('9', '٩');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'الإحصائيات',
          style: TextStyle(fontFamily: 'Tajawal', color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined, color: AppColors.black,))
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward, color: AppColors.black,)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: [
            const SizedBox(height: 20),
            _buildStreakCard(viewModel),
            const SizedBox(height: 20),
            _buildSummaryCards(viewModel),
            const SizedBox(height: 20),
            _buildActivityChartCard(viewModel),
            const SizedBox(height: 30),
            _buildPastDaysStats(viewModel),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(HomeViewModel viewModel) {
    return Card(
      elevation: 0,
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              '${_toArabicNumbers(viewModel.streak.toString())} أيام',
              style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'سلسلة الأيام الحالية',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(HomeViewModel viewModel) {
    final total = viewModel.counters.values.fold(0, (sum, count) => sum + count);
    final dailyAverage = viewModel.dailyAverage;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard('إجمالي التسبيح', _toArabicNumbers(total.toString()), '+١٢٪', Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('المعدل اليومي', _toArabicNumbers(dailyAverage.toString()), '+٥٪', Colors.green),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String change, Color changeColor) {
    return Card(
      elevation: 0,
      color: AppColors.lightGrey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.black, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.arrow_upward, color: changeColor, size: 16),
                const SizedBox(width: 4),
                Text(change, style: TextStyle(fontFamily: 'Tajawal', color: changeColor, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityChartCard(HomeViewModel viewModel) {
    return Card(
      elevation: 0,
      color: AppColors.lightGrey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("النشاط الأسبوعي", style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 30),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 12);
                          Widget text;
                          switch (value.toInt()) {
                            case 0: text = const Text('ج', style: style); break;
                            case 1: text = const Text('س', style: style); break;
                            case 2: text = const Text('ح', style: style); break;
                            case 3: text = const Text('ن', style: style); break;
                            case 4: text = const Text('ث', style: style); break;
                            case 5: text = const Text('ر', style: style); break;
                            case 6: text = const Text('خ', style: style); break;
                            default: text = const Text('', style: style); break;
                          }
                          return SideTitleWidget(axisSide: meta.axisSide, child: text);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: viewModel.weeklyActivity.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastDaysStats(HomeViewModel viewModel) {
    final sortedDays = viewModel.dailyTotals.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    final recentDays = sortedDays.take(7).toList(); // Take the most recent 7 days

    return Column(
      children: List.generate(recentDays.length, (index) { // Use recentDays
        final entry = recentDays[index];
        final date = DateTime.parse(entry.key);
        final count = entry.value;
        final hijriDate = HijriCalendar.fromDate(date);
        String? title;
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
          title = "أمس";
        }

        return _buildPastDayRow(title, hijriDate, count, Icons.calendar_today_outlined);
      }),
    );
  }

  Widget _buildPastDayRow(String? title, HijriCalendar date, int count, IconData icon) {
    final dateString = '${_toArabicNumbers(date.hDay.toString())} ${date.longMonthName} ${_toArabicNumbers(date.hYear.toString())}';

    return Card(
      elevation: 0,
      color: AppColors.lightGrey.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? dateString,
                       style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                     if (title != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        dateString, 
                        style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 14)
                      ),
                    ]
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text(
                  _toArabicNumbers(count.toString()),
                  style: const TextStyle(fontFamily: 'Tajawal', color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18)
                ),
                const SizedBox(height: 2),
                const Text(
                  "تسبيحة",
                  style: TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 14)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
