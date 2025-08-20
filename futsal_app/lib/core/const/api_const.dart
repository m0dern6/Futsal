class ApiConst {
  static const String baseUrl = 'http://144.126.252.228:8080/';
  //auth endpoints
  static const String login = 'User/login';
  static const String register = 'User/register';
  static const String logout = 'User/logout';
  static const String futsalGround = '/FutsalGround';
  static String futsalDetails(String id) => '/FutsalGround/$id';
  static const String trendingGround = '/FutsalGround/trending';
  static const String topReviewGround = '/FutsalGround/top-reviewed';
  //
  static const String userInfo = 'User/manage/info';
  //
  static const String bookFutsal = 'Booking';
}
