import 'package:flutter/material.dart';
import '../data/azkar_data.dart';
import '../models/azkar_item_model.dart';
import '../services/azkar_progress_service.dart';
import '../utils/app_colors.dart';

class AzkarListView extends StatefulWidget {
  final AzkarCategory category;

  const AzkarListView({super.key, required this.category});

  @override
  State<AzkarListView> createState() => _AzkarListViewState();
}

class _AzkarListViewState extends State<AzkarListView> {
  late List<int> _currentCounts;
  bool _allDone = false;

  List<AzkarItem> get _items => azkarData[widget.category] ?? [];

  @override
  void initState() {
    super.initState();
    _currentCounts = _items.map((e) => e.count).toList();
    _allDone = AzkarProgressService.isDone(widget.category.name);
  }

  void _decrement(int index) {
    if (_currentCounts[index] <= 0) return;
    setState(() {
      _currentCounts[index]--;
      _checkAllDone();
    });
  }

  void _checkAllDone() {
    final done = _currentCounts.every((c) => c == 0);
    if (done && !_allDone) {
      _allDone = true;
      AzkarProgressService.markDone(widget.category.name);
      _showCompletionSnackbar();
    }
  }

  void _showCompletionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'أحسنت! أكملت ${widget.category.title} 🤲',
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 15),
          textAlign: TextAlign.right,
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTopBanner(),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Color(0xFFF0F2F8),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    return _ZekrCard(
                      item: _items[index],
                      remaining: _currentCounts[index],
                      onTap: () => _decrement(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_forward,
              color: Color(0xFF888888),
              size: 22,
            ),
          ),
          Text(
            widget.category.title,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _allDone
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          _allDone
              ? 'بارك الله فيك، أكملت ${widget.category.title} ✓'
              : 'اضغط على كل ذكر لتسجيل عدد مراته',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _allDone
                ? const Color(0xFF43A047)
                : const Color(0xFF4F8EF7),
          ),
        ),
      ),
    );
  }
}

class _ZekrCard extends StatelessWidget {
  final AzkarItem item;
  final int remaining;
  final VoidCallback onTap;

  const _ZekrCard({
    required this.item,
    required this.remaining,
    required this.onTap,
  });

  String _formatCount(int count) {
    if (count == 1) return 'مرة واحدة';
    if (count == 2) return 'مرتان';
    if (count <= 10) return '$count مرات';
    return '$count مرة';
  }

  @override
  Widget build(BuildContext context) {
    final bool done = remaining == 0;

    return GestureDetector(
      onTap: done ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: done
                    ? const Color(0xFFAAAAAA)
                    : const Color(0xFF1A1A2E),
                height: 1.9,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (done)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, size: 13, color: Color(0xFF43A047)),
                        SizedBox(width: 4),
                        Text(
                          'تم',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatCount(remaining),
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F8EF7),
                      ),
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