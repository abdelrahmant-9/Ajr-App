class AjrModel {
  final Map<String, int> counters;
  final String currentZekr;
  final DateTime lastUpdated;
  final Map<String, int> todayCounters;
  final DateTime lastResetDate;
  final List<DateTime> usageDates;
  final Map<String, int> dailyTotals; 

  AjrModel({
    required this.counters,
    required this.currentZekr,
    required this.lastUpdated,
    required this.todayCounters,
    required this.lastResetDate,
    required this.usageDates,
    required this.dailyTotals,
  });

  Map<String, dynamic> toMap() {
    return {
      "counters": counters,
      "currentZekr": currentZekr,
      "lastUpdated": lastUpdated.toIso8601String(),
      "todayCounters": todayCounters,
      "lastResetDate": lastResetDate.toIso8601String(),
      "usageDates": usageDates.map((d) => d.toIso8601String()).toList(),
      "dailyTotals": dailyTotals,
    };
  }

  factory AjrModel.fromMap(Map<String, dynamic> map) {
    return AjrModel(
      counters: Map<String, int>.from(map["counters"] ?? {}),
      currentZekr: map["currentZekr"] ?? 'سبحان الله',
      lastUpdated: DateTime.parse(map["lastUpdated"] ?? DateTime.now().toIso8601String()),
      todayCounters: Map<String, int>.from(map["todayCounters"] ?? {}),
      lastResetDate: DateTime.parse(map["lastResetDate"] ?? DateTime.now().toIso8601String()),
      usageDates: (map['usageDates'] as List<dynamic>? ?? []).map((d) => DateTime.parse(d as String)).toList(),
      dailyTotals: Map<String, int>.from(map["dailyTotals"] ?? {}),
    );
  }
}
