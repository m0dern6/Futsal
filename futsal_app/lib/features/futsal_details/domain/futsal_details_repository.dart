import 'package:futsalpay/features/futsal_details/data/model/futsal_details_model.dart';

abstract class FutsalDetailsRepository {
  Future<FutsalDetailsModel> getFutsalDetails(String id);
}
