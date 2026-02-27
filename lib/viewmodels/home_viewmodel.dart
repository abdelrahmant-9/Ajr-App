import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/repository/ajr_repository.dart';
import '../models/ajr_model.dart';

class HomeViewModel extends ChangeNotifier {
  final repository = AjrRepository();

  // New data structure
  Map<String, int> _counters = {};
  String _currentZekr = "سبحان الله";

  bool _isLoading = true;

  // Getters using the new structure
  int get counter => _counters[_currentZekr] ?? 0;
  String get currentZekr => _currentZekr;
  Map<String, int> get counters => _counters; // Added getter for stats
  double get progress => isLoading ? 0.0 : (counter / goal).clamp(0.0, 1.0);
  bool get isLoading => _isLoading;

  final int goal = 100;

  List<String> _azkar = [];
  List<String> get azkar => _azkar;

  HomeViewModel() {
    _loadAzkar();
  }

  void _saveModel() {
    repository.save(
      AjrModel(
        counters: _counters,
        currentZekr: _currentZekr,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void _loadAzkar() {
    final box = Hive.box('ajrBox');
    _azkar = box.get('azkar', defaultValue: [
      "سبحان الله",
      "الحمد لله",
      "الله أكبر",
      "لا إله إلا الله",
      "استغفر الله",
    ]).cast<String>();
  }

  void _saveAzkar() {
    Hive.box('ajrBox').put('azkar', _azkar);
    notifyListeners();
  }

  Future<void> init() async {
    _isLoading = true;
    try {
      final AjrModel model = await repository.get();
      _counters = model.counters;
      _currentZekr = model.currentZekr;
    } catch (e) {
      // Handle case where loading fails or data is in old format.
      // Initialize with default values.
      _counters = {};
      _currentZekr = _azkar.isNotEmpty ? _azkar.first : "سبحان الله";
    }

    // Ensure all azkar from the list have a counter entry.
    for (final zekr in _azkar) {
      _counters.putIfAbsent(zekr, () => 0);
    }
    _counters.putIfAbsent(_currentZekr, () => 0);

    _isLoading = false;
    notifyListeners();
  }

  void changeZekr(String newZekr) {
    if (_currentZekr == newZekr) return;

    _currentZekr = newZekr;
    _counters.putIfAbsent(newZekr, () => 0); // Ensure counter exists for new zekr

    notifyListeners();
    _saveModel();
  }

  void addCustomZekr(String zekr) {
    if (zekr.trim().isNotEmpty && !_azkar.contains(zekr.trim())) {
      _azkar.add(zekr.trim());
      _counters.putIfAbsent(zekr.trim(), () => 0);
      _saveAzkar();
      _saveModel();
    }
  }

  void removeZekr(String zekr) {
    _azkar.remove(zekr);
    _counters.remove(zekr);
    if (_currentZekr == zekr) {
      _currentZekr = _azkar.isNotEmpty ? _azkar.first : "سبحان الله";
    }
    _saveAzkar();
    _saveModel();
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
    _counters[_currentZekr] = counter + 1;
    notifyListeners();
    _saveModel();
  }

  void reset() {
    // This now resets the counter for the *current* zekr
    _counters[_currentZekr] = 0;
    notifyListeners();
    _saveModel();
  }
}
