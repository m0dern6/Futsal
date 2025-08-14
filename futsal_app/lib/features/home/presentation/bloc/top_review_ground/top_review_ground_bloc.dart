import 'package:bloc/bloc.dart';
import 'package:futsalpay/features/home/data/model/top_review_ground_model.dart';
import 'package:futsalpay/features/home/domain/top_review_ground_repository.dart';
import 'package:equatable/equatable.dart';

part 'top_review_ground_event.dart';
part 'top_review_ground_state.dart';

class TopReviewGroundBloc
    extends Bloc<TopReviewGroundEvent, TopReviewGroundState> {
  final TopReviewGroundRepository _topReviewGroundRepository;

  TopReviewGroundBloc(this._topReviewGroundRepository)
    : super(TopReviewGroundInitial()) {
    on<LoadTopReviewGrounds>((event, emit) async {
      emit(TopReviewGroundLoading());
      try {
        final grounds = await _topReviewGroundRepository.getTopReviewGrounds(
          page: event.page ?? 1,
          pageSize: event.pageSize ?? 10,
        );
        emit(TopReviewGroundLoaded(grounds));
      } catch (e) {
        emit(TopReviewGroundError(e.toString()));
      }
    });
  }
}
