class AjrModel {
  final Map<String, int> counters;
  final String currentZekr;
  final DateTime lastUpdated;

  AjrModel({
    required this.counters,
    required this.currentZekr,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      "counters": counters,
      "currentZekr": currentZekr,
      "lastUpdated": lastUpdated.toIso8601String(),
    };
  }

  factory AjrModel.fromMap(Map<String, dynamic> map) {
    return AjrModel(
      counters: Map<String, int>.from(map["counters"]),
      currentZekr: map["currentZekr"],
      lastUpdated: DateTime.parse(map["lastUpdated"]),
    );
  }
}
