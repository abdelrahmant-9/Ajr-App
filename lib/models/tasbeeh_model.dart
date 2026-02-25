class TasbeehModel {
  final int counter;
  final DateTime lastUpdated;

  TasbeehModel({
    required this.counter,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'counter': counter,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory TasbeehModel.fromMap(Map<String, dynamic> map) {
    return TasbeehModel(
      counter: map['counter'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
