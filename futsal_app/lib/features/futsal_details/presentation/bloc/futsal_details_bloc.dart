import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:futsalpay/features/futsal_details/domain/futsal_details_repository.dart';
import 'package:futsalpay/features/futsal_details/data/model/futsal_details_model.dart';

part 'futsal_details_event.dart';
part 'futsal_details_state.dart';

class FutsalDetailsBloc extends Bloc<FutsalDetailsEvent, FutsalDetailsState> {
  final FutsalDetailsRepository repository;
  FutsalDetailsBloc(this.repository) : super(FutsalDetailsInitial()) {
    on<LoadFutsalDetails>(_onLoadDetails);
  }

  Future<void> _onLoadDetails(
    LoadFutsalDetails event,
    Emitter<FutsalDetailsState> emit,
  ) async {
    emit(FutsalDetailsLoading());
    try {
      final FutsalDetailsModel data = await repository.getFutsalDetails(
        event.id,
      );
      emit(FutsalDetailsLoaded(data));
    } catch (e) {
      emit(FutsalDetailsError(e.toString()));
    }
  }
}
