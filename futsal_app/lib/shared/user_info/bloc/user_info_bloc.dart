import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:futsalpay/shared/user_info/data/model/user_info_model.dart';
import 'package:futsalpay/shared/user_info/data/repository/user_info_repository.dart';

part 'user_info_event.dart';
part 'user_info_state.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final UserInfoRepository userInfoRepository;
  static UserInfoModel? _userInfo; // Universal getter

  UserInfoBloc(this.userInfoRepository) : super(UserInfoInitial()) {
    on<LoadUserInfo>((event, emit) async {
      emit(UserInfoLoading());
      try {
        final userInfo = await userInfoRepository.fetchUserInfo();
        _userInfo = userInfo;

        emit(UserInfoLoaded(userInfo));
      } catch (e) {
        emit(UserInfoError(e.toString()));
      }
    });
  }

  static UserInfoModel? get userInfo => _userInfo;
}
