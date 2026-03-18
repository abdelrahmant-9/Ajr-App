import 'package:hive/hive.dart';

class AzkarProgressService {
  static const String _boxName = 'azkarProgress';

  static String _todayKey(String category) {
    final today = DateTime.now();
    return '${category}_${today.year}_${today.month}_${today.day}';
  }

  static Future<void> markDone(String category) async {
    final box = Hive.box(_boxName);
    await box.put(_todayKey(category), true);
  }

  static bool isDone(String category) {
    final box = Hive.box(_boxName);
    return box.get(_todayKey(category), defaultValue: false) as bool;
  }

  // Returns how many categories are done today out of total
  static Map<String, bool> getTodayProgress(List<String> categories) {
    return {
      for (final cat in categories) cat: isDone(cat),
    };
  }
}