import 'package:bloc/bloc.dart';
import 'package:futsalpay/features/home/data/model/trending_ground_model.dart';
import 'package:futsalpay/features/home/domain/trending_ground_repository.dart';
import 'package:equatable/equatable.dart';

part 'trending_ground_event.dart';
part 'trending_ground_state.dart';

class TrendingGroundBloc
    extends Bloc<TrendingGroundEvent, TrendingGroundState> {
  final TrendingGroundRepository _trendingGroundRepository;

  TrendingGroundBloc(this._trendingGroundRepository)
    : super(TrendingGroundInitial()) {
    on<LoadTrendingGrounds>((event, emit) async {
      emit(TrendingGroundLoading());
      try {
        final grounds = await _trendingGroundRepository.getTrendingGrounds(
          page: event.page ?? 1,
          pageSize: event.pageSize ?? 10,
        );
        emit(TrendingGroundLoaded(grounds));
      } catch (e) {
        emit(TrendingGroundError(e.toString()));
      }
    });
  }
}
