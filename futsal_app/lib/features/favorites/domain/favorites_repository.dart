import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

abstract class FavoritesRepository {
  Future<List<FutsalGroundModel>> getFavoriteGrounds();
  Future<void> addFavorite(String groundId);
}
