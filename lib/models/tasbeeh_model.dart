class TasbeehModel {
  final Map<String, int> counters;
  final String currentZekr;
  final DateTime lastUpdated;

  TasbeehModel({
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

  factory TasbeehModel.fromMap(Map<String, dynamic> map) {
    return TasbeehModel(
      counters: Map<String, int>.from(map["counters"]),
      currentZekr: map["currentZekr"],
      lastUpdated: DateTime.parse(map["lastUpdated"]),
    );
  }
}
