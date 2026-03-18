import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../services/notification_service.dart';

class DebugDashboard extends StatefulWidget {
  const DebugDashboard({super.key});

  @override
  State<DebugDashboard> createState() => _DebugDashboardState();
}

class _DebugDashboardState extends State<DebugDashboard> {
  Map<String, dynamic> _hiveData = {};
  Map<String, dynamic> _prefsData = {};
  Map<String, dynamic> _firebaseData = {};
  String _firebaseStatus = '...';
  bool _loading = true;
  
  // Notification States
  int _pendingCount = 0;
  List<PendingNotificationRequest> _pendingList = [];
  bool _notificationsEnabled = true;
  String _nextTime = '-';

  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadNotifications();
    _checkNotificationPermission();
    _loadNextTime();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await Future.wait([_loadHive(), _loadPrefs(), _loadFirebase()]);
    setState(() => _loading = false);
  }

  Future<void> _loadNotifications() async {
    final pending = await NotificationService().pendingNotifications();
    setState(() {
      _pendingCount = pending.length;
      _pendingList = pending;
    });
  }

  Future<void> _checkNotificationPermission() async {
    final androidPlugin = NotificationService()
        .plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final enabled = await androidPlugin?.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled ?? true;
    });
  }

  Future<void> _loadNextTime() async {
    final prefs = await SharedPreferences.getInstance();
    final h = prefs.getInt('reminder_hour');
    final m = prefs.getInt('reminder_minute');

    if (h != null && m != null) {
      setState(() {
        _nextTime = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      });
    } else {
      setState(() {
        _nextTime = '-';
      });
    }
  }

  /// فتح إعدادات البطارية بشكل أدق
  Future<void> _openBatterySettings() async {
    if (Platform.isAndroid) {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final intent = AndroidIntent(
          action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          data: 'package:${packageInfo.packageName}', // توجيه مباشر للتطبيق
        );
        await intent.launch();
      } catch (e) {
        // لو الطريقة المباشرة فشلت، نفتح الصفحة العامة
        try {
          const intent = AndroidIntent(
            action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
          );
          await intent.launch();
        } catch (e2) {
          _showSnack('Error opening settings: $e2');
        }
      }
    } else {
      _showSnack('Battery settings only available on Android');
    }
  }

  Future<void> _loadHive() async {
    final box = Hive.box('ajrBox');
    final map = <String, dynamic>{};
    for (final key in box.keys) {
      map[key.toString()] = box.get(key).toString();
    }
    setState(() => _hiveData = map);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};
    for (final key in prefs.getKeys()) {
      map[key] = prefs.get(key).toString();
    }
    setState(() => _prefsData = map);
  }

  Future<void> _loadFirebase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _firebaseStatus = '❌ Not signed in';
          _firebaseData = {};
        });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      setState(() {
        _firebaseStatus = doc.exists ? '✅ Connected (uid: $uid)' : '⚠️ No data yet';
        _firebaseData = doc.exists
            ? doc.data()!.map((k, v) => MapEntry(k, v.toString()))
            : {};
      });
    } catch (e) {
      setState(() {
        _firebaseStatus = '❌ Error: $e';
        _firebaseData = {};
      });
    }
  }

  Future<void> _clearHive() async {
    await Hive.box('ajrBox').clear();
    _showSnack('✅ Hive cleared');
    _loadHive();
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _showSnack('✅ SharedPreferences cleared');
    _loadPrefs();
  }

  Future<void> _clearFirebase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      _showSnack('✅ Firebase doc deleted');
      _loadFirebase();
    } catch (e) {
      _showSnack('❌ $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Tajawal')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('📋 Copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.bug_report, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Debug Dashboard',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              _loadAll();
              _loadNotifications();
              _checkNotificationPermission();
              _loadNextTime();
            },
            tooltip: 'Refresh all',
          ),
        ],
      ),
      body: _loading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Notifications ──────────────────────────────
          _buildSection(
            title: '🔔 Notifications',
            color: Colors.orangeAccent,
            actions: [
              _actionButton(
                label: 'Fix Battery',
                icon: Icons.battery_alert,
                color: Colors.redAccent,
                onTap: _openBatterySettings,
              ),
              _actionButton(
                label: 'Schedule 1 min',
                icon: Icons.timer,
                color: Colors.greenAccent,
                onTap: () async {
                  final now = TimeOfDay.now();
                  int newMinute = now.minute + 1;
                  int newHour = now.hour;
                  if (newMinute >= 60) {
                    newMinute = 0;
                    newHour = (newHour + 1) % 24;
                  }
                  await NotificationService().scheduleDailyReminder(
                    TimeOfDay(hour: newHour, minute: newMinute),
                  );
                  _showSnack('⏱ Scheduled after 1 min');
                  _loadNotifications();
                  _loadNextTime();
                },
              ),
              _actionButton(
                label: 'Send Test',
                icon: Icons.send,
                color: Colors.orangeAccent,
                onTap: () async {
                  await NotificationService().sendTestNotification();
                  _showSnack('📨 Test notification sent');
                },
              ),
              _actionButton(
                label: 'Cancel All',
                icon: Icons.notifications_off,
                color: Colors.red,
                onTap: () async {
                  await NotificationService().cancelDailyReminder();
                  _showSnack('🔕 Notifications cancelled');
                  _loadNotifications();
                  _loadNextTime();
                },
              ),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataRow('Pending Notifications', _pendingCount.toString()),
                _dataRow(
                  'Daily Reminder Status',
                  _pendingCount > 0 ? 'ON ✅' : 'OFF ❌',
                ),
                _dataRow(
                  'Notifications Permission',
                  _notificationsEnabled ? 'ENABLED ✅' : 'DISABLED ❌',
                ),
                _dataRow('Next Reminder Time', _nextTime),
                _dataRow(
                  'Battery Optimization',
                  _pendingCount > 0 ? 'Check manually ⚠️' : '-',
                ),
                if (_pendingCount > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Tip: Click "Fix Battery" to disable optimization',
                      style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontFamily: 'Tajawal'),
                    ),
                  ),
                if (_pendingList.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Pending IDs:', style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
                  ..._pendingList.map(
                        (e) => _dataRow('ID', e.id.toString()),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Settings (SharedPrefs) ─────────────────────
          _buildSection(
            title: '⚙️ Settings',
            color: Colors.blueAccent,
            actions: [
              _actionButton(
                label: 'Clear Prefs',
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: _clearPrefs,
              ),
            ],
            content: _prefsData.isEmpty
                ? _emptyLabel('No prefs saved yet')
                : Column(
              children: _prefsData.entries
                  .map((e) => _dataRow(e.key, e.value))
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Hive Local Data ────────────────────────────
          _buildSection(
            title: '📦 Hive Data',
            color: Colors.purpleAccent,
            actions: [
              _actionButton(
                label: 'Clear Hive',
                icon: Icons.delete_sweep,
                color: Colors.red,
                onTap: _clearHive,
              ),
            ],
            content: _hiveData.isEmpty
                ? _emptyLabel('Hive box is empty')
                : Column(
              children: _hiveData.entries
                  .map((e) => _dataRow(e.key, e.value))
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Firebase Sync ──────────────────────────────
          _buildSection(
            title: '🔥 Firebase Sync',
            color: Colors.redAccent,
            actions: [
              _actionButton(
                label: 'Refresh',
                icon: Icons.sync,
                color: Colors.greenAccent,
                onTap: _loadFirebase,
              ),
              _actionButton(
                label: 'Delete Doc',
                icon: Icons.delete_forever,
                color: Colors.red,
                onTap: _clearFirebase,
              ),
            ],
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataRow('Status', _firebaseStatus),
                if (_firebaseData.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._firebaseData.entries
                      .map((e) => _dataRow(e.key, e.value))
                      .toList(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Counters & Stats ───────────────────────────
          _buildSection(
            title: '📊 Stats',
            color: Colors.tealAccent,
            actions: [],
            content: Builder(builder: (context) {
              final box = Hive.box('ajrBox');
              final raw = box.get('ajr');
              if (raw == null) return _emptyLabel('No ajr data in Hive');
              final data = Map<String, dynamic>.from(raw as Map);
              final counters = data['counters'] ?? {};
              final todayCounters = data['todayCounters'] ?? {};
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subTitle('All-time counters'),
                  ...Map<String, dynamic>.from(counters)
                      .entries
                      .map((e) => _dataRow(e.key, e.value.toString()))
                      .toList(),
                  const SizedBox(height: 8),
                  _subTitle('Today counters'),
                  ...Map<String, dynamic>.from(todayCounters)
                      .entries
                      .map((e) => _dataRow(e.key, e.value.toString()))
                      .toList(),
                  const SizedBox(height: 8),
                  _dataRow('lastUpdated', data['lastUpdated'] ?? '-'),
                  _dataRow('lastResetDate', data['lastResetDate'] ?? '-'),
                  _dataRow(
                      'usageDates count',
                      ((data['usageDates'] as List?)?.length ?? 0)
                          .toString()),
                ],
              );
            }),
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              '⚠️  Developer only — remove before release',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Colors.white24,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    required Color color,
    required List<Widget> actions,
    required Widget? content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontFamily: 'monospace', color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String key, String value) {
    return GestureDetector(
      onLongPress: () => _copyToClipboard('$key: $value'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                key,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ),
            const Text(' → ',
                style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white24,
                    fontSize: 11)),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white70,
                  fontSize: 11,
                ),
                overflow: TextOverflow.clip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      '▸ $text',
      style: const TextStyle(
        fontFamily: 'monospace',
        color: Colors.tealAccent,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _emptyLabel(String text) => Text(
    text,
    style: const TextStyle(
        fontFamily: 'monospace', color: Colors.white24, fontSize: 11),
  );
}
