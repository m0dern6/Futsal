class ApiConst {
  // Update this to match your actual server URL - use localhost if testing locally, or your production URL
  static const String baseUrl = 'http://144.126.252.228:8080/';

  //auth endpoints
  static const String login = 'User/login';
  static const String refresh = 'User/refresh';
  static const String register = 'User/register';
  static const String logout = 'User/logout';

  // Fixed futsal ground endpoints (removed leading slash)
  static const String futsalGround = 'FutsalGround';
  static String futsalDetails(String id) => 'FutsalGround/$id';
  static const String trendingGround = 'FutsalGround/trending';
  static const String topReviewGround = 'FutsalGround/top-reviewed';
  static const String favorites = 'FutsalGround/favourites';
  static String addFavorite(String groundId) =>
      'FutsalGround/favourite/$groundId';

  // Other endpoints
  static const String uploadImage = 'images/upload/single';
  static const String userInfo = 'User/manage/info';
  static const String bookFutsal = 'Booking';
}
