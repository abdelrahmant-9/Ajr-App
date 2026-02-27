import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repository/ajr_repository.dart';

class SyncService {
  final _repository = AjrRepository();
  StreamSubscription? _subscription;

  void start() {
    print("SyncService started");

    _subscription =
        Connectivity().onConnectivityChanged.listen((result) async {
          print("Connectivity changed: $result");

          if (result != ConnectivityResult.none) {
            print("Internet detected → syncing...");
            await _repository.sync();
          }
        });
  }

  void dispose() {
    _subscription?.cancel();
  }
}