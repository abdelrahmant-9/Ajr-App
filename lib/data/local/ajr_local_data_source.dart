import 'package:hive/hive.dart';
import '../../models/ajr_model.dart';

class AjrLocalDataSource {
  final box = Hive.box('ajrBox');

  void save(AjrModel model) {
    box.put('ajr', model.toMap());
  }

  AjrModel? load() {
    final data = box.get('ajr');
    if (data == null) return null;
    return AjrModel.fromMap(Map<String, dynamic>.from(data));
  }
}
