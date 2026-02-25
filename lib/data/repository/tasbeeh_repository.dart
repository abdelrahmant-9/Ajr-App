import '../local/tasbeeh_local_data_source.dart';
import '../remote/tasbeeh_remote_data_source.dart';
import '../../models/tasbeeh_model.dart';

class TasbeehRepository {
  final local = TasbeehLocalDataSource();
  final remote = TasbeehRemoteDataSource();

  Future<TasbeehModel> get() async {
    final localModel = local.load();
    try {
      final remoteModel = await remote.load();

      if (remoteModel == null) {
        if (localModel != null) {
          await remote.save(localModel);
        }
        return localModel ?? TasbeehModel(counter: 0, lastUpdated: DateTime.now());
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
          TasbeehModel(counter: 0, lastUpdated: DateTime.now());
    }
  }

  Future<void> save(TasbeehModel model) async {
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
