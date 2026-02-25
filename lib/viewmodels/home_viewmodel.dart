import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/repository/tasbeeh_repository.dart';
import '../models/tasbeeh_model.dart';

class HomeViewModel extends ChangeNotifier {
  final repository = TasbeehRepository();

  late TasbeehModel model;
  bool _isLoading = true;

  final int goal = 100;
  double get progress => isLoading ? 0.0 : (model.counter / goal).clamp(0.0, 1.0);
  bool get isLoading => _isLoading;

  // --- Zekr Management ---
  List<String> _azkar = [];
  List<String> get azkar => _azkar;

  String _currentZekr = "سبحان الله";
  String get currentZekr => _currentZekr;

  HomeViewModel() {
    _loadAzkar();
    _loadZekr();
  }

  void _loadAzkar() {
    final box = Hive.box('tasbeehBox');
    _azkar = box.get('azkar', defaultValue: [
      "سبحان الله",
      "الحمد لله",
      "الله أكبر",
      "لا إله إلا الله",
      "استغفر الله",
    ]).cast<String>();
  }

  void _saveAzkar() {
    Hive.box('tasbeehBox').put('azkar', _azkar);
    notifyListeners();
  }

  void _loadZekr() {
    final box = Hive.box('tasbeehBox');
    _currentZekr = box.get('currentZekr', defaultValue: "سبحان الله");
  }

  Future<void> init() async {
    _isLoading = true;
    model = await repository.get();
    _isLoading = false;
    notifyListeners();
  }

  void changeZekr(String newZekr) {
    if (_currentZekr == newZekr) return;

    _currentZekr = newZekr;
    model = TasbeehModel(
      counter: 0,
      lastUpdated: DateTime.now(),
    );
    Hive.box('tasbeehBox').put('currentZekr', newZekr);
    notifyListeners();
    repository.save(model);
  }

  void addCustomZekr(String zekr) {
    if (zekr.isEmpty || _azkar.contains(zekr)) return;
    _azkar.add(zekr);
    _saveAzkar();
  }

  void removeZekr(String zekr) {
    _azkar.remove(zekr);
    _saveAzkar();
  }

  void reorderZekr(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _azkar.removeAt(oldIndex);
    _azkar.insert(newIndex, item);
    _saveAzkar();
  }

  void increment() {
    model = TasbeehModel(
      counter: model.counter + 1,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    repository.save(model);
  }

  void reset() {
    model = TasbeehModel(
      counter: 0,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    repository.save(model);
  }
}
