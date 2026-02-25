import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _count = 0;
  int _goal = 100;

  int get count => _count;
  int get goal => _goal;

  double get progress => _count / _goal;

  void increment() {
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }
}