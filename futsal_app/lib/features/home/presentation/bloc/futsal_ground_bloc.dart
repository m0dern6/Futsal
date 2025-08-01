import 'package:bloc/bloc.dart';
import 'package:futsalpay/features/home/data/model/futsal_ground_model.dart';

import 'package:futsalpay/features/home/domain/futsal_ground_repository.dart';
import 'package:equatable/equatable.dart';
part 'futsal_ground_event.dart';
part 'futsal_ground_state.dart';

class FutsalGroundBloc extends Bloc<FutsalGroundEvent, FutsalGroundState> {
  final FutsalGroundRepository _futsalGroundRepository;

  FutsalGroundBloc(this._futsalGroundRepository)
    : super(FutsalGroundInitial()) {
    on<LoadFutsalGrounds>((event, emit) async {
      emit(FutsalGroundLoading());
      try {
        final grounds = await _futsalGroundRepository.getFutsalGrounds(
          page: 1,
          pageSize: 10,
        );
        emit(FutsalGroundLoaded(grounds));
      } catch (e) {
        emit(FutsalGroundError(e.toString()));
      }
    });
  }
}
