import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../services/notification_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _dailyReminderEnabled = true;
  int _dailyGoal = 100;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? true;
      _dailyGoal = prefs.getInt('daily_goal') ?? 100;
      final hour = prefs.getInt('reminder_hour') ?? 20;
      final minute = prefs.getInt('reminder_minute') ?? 0;
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('daily_reminder_enabled', _dailyReminderEnabled);
    await prefs.setInt('daily_goal', _dailyGoal);
    await prefs.setInt('reminder_hour', _reminderTime.hour);
    await prefs.setInt('reminder_minute', _reminderTime.minute);
  }

  Future<void> _applyReminderSettings() async {
    if (_dailyReminderEnabled) {
      await NotificationService().scheduleDailyReminder(_reminderTime);
    } else {
      await NotificationService().cancelDailyReminder();
    }
  }

  String _toArabicNumbers(String number) {
    return number
        .replaceAll('0', '٠').replaceAll('1', '١').replaceAll('2', '٢')
        .replaceAll('3', '٣').replaceAll('4', '٤').replaceAll('5', '٥')
        .replaceAll('6', '٦').replaceAll('7', '٧').replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '${_toArabicNumbers(hour.toString())}:${_toArabicNumbers(minute)} $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      await _saveSettings();
      await _applyReminderSettings();
    }
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
          icon: const Icon(Icons.arrow_forward, color: AppColors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('الإعدادات',
            style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            // ── التفاعل ──────────────────────────────────────
            _buildSectionTitle('التفاعل'),
            _buildCard(children: [
              _buildToggleRow(
                title: 'صوت التسبيح',
                subtitle: 'تشغيل نغمة عند كل تسبيحة',
                icon: Icons.volume_up_outlined,
                value: _soundEnabled,
                onChanged: (v) {
                  setState(() => _soundEnabled = v);
                  _saveSettings();
                },
              ),
              const Divider(height: 1, color: AppColors.lightGrey),
              _buildToggleRow(
                title: 'الاهتزاز',
                subtitle: 'اهتزاز خفيف عند الضغط',
                icon: Icons.vibration_outlined,
                value: _vibrationEnabled,
                onChanged: (v) {
                  setState(() => _vibrationEnabled = v);
                  _saveSettings();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ── الأهداف اليومية ───────────────────────────────
            _buildSectionTitle('الأهداف اليومية'),
            _buildCard(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _iconBox(Icons.track_changes_outlined),
                      const SizedBox(width: 12),
                      const Text('هدفي اليومي',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black)),
                    ]),
                    Text(_toArabicNumbers(_dailyGoal.toString()),
                        style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _dailyGoal > 10
                          ? () {
                        setState(() => _dailyGoal -= 10);
                        _saveSettings();
                      }
                          : null,
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('١٠',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('تعديل',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() => _dailyGoal += 10);
                        _saveSettings();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('١٠',
                          style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 14,
                              color: AppColors.black)),
                    ),
                  ),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 14, right: 16, left: 16),
                child: Text(
                  'سيتم إرسال تنبيه لك عند وصولك لهذا الهدف',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: AppColors.darkGrey),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // ── التنبيهات والذكر ──────────────────────────────
            _buildSectionTitle('التنبيهات والذكر'),
            _buildCard(children: [
              _buildToggleRow(
                title: 'التذكير اليومي',
                subtitle: 'تنبه بوقت الأذكار المفضل',
                icon: Icons.notifications_outlined,
                value: _dailyReminderEnabled,
                onChanged: (v) async {
                  setState(() => _dailyReminderEnabled = v);
                  await _saveSettings();
                  await _applyReminderSettings();
                },
              ),
              const Divider(height: 1, color: AppColors.lightGrey),
              InkWell(
                onTap: _dailyReminderEnabled ? _pickTime : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        _iconBox(Icons.access_time_outlined),
                        const SizedBox(width: 12),
                        const Text('وقت التذكير',
                            style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black)),
                      ]),
                      Opacity(
                        opacity: _dailyReminderEnabled ? 1.0 : 0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_formatTime(_reminderTime),
                              style: const TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // ── تقييم + مشاركة ────────────────────────────────
            _buildCard(children: [
              _buildArrowRow(
                title: 'تقييم التطبيق',
                icon: Icons.star_outline_rounded,
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.lightGrey),
              _buildArrowRow(
                title: 'مشاركة مع الأصدقاء',
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 32),

            // ── Footer ────────────────────────────────────────
            const Center(
              child: Text('تطبيق أجر · الإصدار 1.0.0',
                  style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: AppColors.darkGrey)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text('سياسة الخصوصية',
                      style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {},
                  child: const Text('شروط الاستخدام',
                      style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: AppColors.primary, size: 22),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10, right: 4),
    child: Text(title,
        style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey)),
  );

  Widget _buildCard({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Row(children: [
              _iconBox(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: AppColors.darkGrey)),
                  ],
                ),
              ),
            ]),
          ),
          Switch.adaptive(
              value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ]),
      );

  Widget _buildArrowRow({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                _iconBox(icon),
                const SizedBox(width: 12),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black)),
              ]),
              const Icon(Icons.chevron_left, color: AppColors.darkGrey),
            ],
          ),
        ),
      );
}