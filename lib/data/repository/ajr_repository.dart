import '../local/ajr_local_data_source.dart';
import '../remote/ajr_remote_data_source.dart';
import '../../models/ajr_model.dart';

class AjrRepository {
  final local = AjrLocalDataSource();
  final remote = AjrRemoteDataSource();

  Future<AjrModel> get() async {
    final localModel = local.load();
    try {
      final remoteModel = await remote.load();

      if (remoteModel == null) {
        if (localModel != null) {
          await remote.save(localModel);
        }
        return localModel ??
            AjrModel(
              counters: {"سبحان الله": 0},
              currentZekr: "سبحان الله",
              lastUpdated: DateTime.now(),
              todayCounters: {"سبحان الله": 0},
              lastResetDate: DateTime.now(),
              usageDates: [],
              dailyTotals: {}, // Added missing field
            );
      } else {
        if (localModel == null ||
            remoteModel.lastUpdated.isAfter(localModel.lastUpdated)) {
          local.save(remoteModel);
          return remoteModel;
        }
        return localModel;
      }
    } catch (_) {
      return localModel ??
          AjrModel(
            counters: {"سبحان الله": 0},
            currentZekr: "سبحان الله",
            lastUpdated: DateTime.now(),
            todayCounters: {"سبحان الله": 0},
            lastResetDate: DateTime.now(),
            usageDates: [],
            dailyTotals: {}, // Added missing field
          );
    }
  }

  Future<void> save(AjrModel model) async {
    local.save(model);

    try {
      await remote.save(model);
    } catch (_) {}
  }

  Future<void> sync() async {
    final localModel = local.load();
    if (localModel == null) return;

    try {
      await remote.save(localModel);
    } catch (_) {}
  }
}
