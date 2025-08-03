import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

abstract class FutsalGroundRepository {
  Future<List<FutsalGroundModel>> getFutsalGrounds({
    required int page,
    required int pageSize,
  });
}
