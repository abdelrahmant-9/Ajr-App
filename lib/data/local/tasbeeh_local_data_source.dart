import 'package:hive/hive.dart';
import '../../models/tasbeeh_model.dart';

class TasbeehLocalDataSource {
  final box = Hive.box('tasbeehBox');

  void save(TasbeehModel model) {
    box.put('tasbeeh', model.toMap());
  }

  TasbeehModel? load() {
    final data = box.get('tasbeeh');
    if (data == null) return null;
    return TasbeehModel.fromMap(Map<String, dynamic>.from(data));
  }
}
