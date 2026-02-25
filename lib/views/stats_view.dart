import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ajr/utils/app_colors.dart';
import '../viewmodels/home_viewmodel.dart';

class StatsView extends StatefulWidget {
  const StatsView({super.key});

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  int _selectedChipIndex = 0;

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
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('الإجمالي'),
                    selected: _selectedChipIndex == 0,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChipIndex = 0;
                        });
                      }
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      color: _selectedChipIndex == 0 ? AppColors.primary : AppColors.darkGrey,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: _selectedChipIndex == 0 ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    backgroundColor: AppColors.lightGrey,
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('اليوم'),
                    selected: _selectedChipIndex == 1,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedChipIndex = 1;
                        });
                      }
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.bold,
                      color: _selectedChipIndex == 1 ? AppColors.primary : AppColors.darkGrey,
                    ),
                     shape: StadiumBorder(
                      side: BorderSide(
                        color: _selectedChipIndex == 1 ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    backgroundColor: AppColors.lightGrey,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Content based on selection
              Expanded(
                child: _selectedChipIndex == 0
                    ? _buildTotalStats(viewModel)
                    : _buildTodayStats(viewModel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalStats(HomeViewModel viewModel) {
    var sortedCounters = viewModel.counters.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCounters.every((e) => e.value == 0)) {
       return const Center(
        child: Text(
          'لا توجد بيانات لعرضها بعد',
          style: TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 18),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: sortedCounters.length,
      itemBuilder: (context, index) {
        final entry = sortedCounters[index];
        final zekr = entry.key;
        final count = entry.value;

        if (count == 0) return const SizedBox.shrink(); // Don't show empty counters

        return Card(
          elevation: 0,
          color: AppColors.lightGrey.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              zekr,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            trailing: Text(
              _toArabicNumbers(count.toString()),
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayStats(HomeViewModel viewModel) {
    return const Center(
      child: Text(
        'إحصائيات اليوم ستكون متاحة قريباً',
        style: TextStyle(fontFamily: 'Tajawal', color: AppColors.darkGrey, fontSize: 18),
      ),
    );
  }
}
