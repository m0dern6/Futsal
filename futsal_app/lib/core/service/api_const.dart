class ApiConst {
  static const String baseUrl = 'http://144.126.252.228:8080/';

  // auth endpoints
  static const String login = 'User/login';
  static const String refresh = 'User/refresh';
  static const String register = 'User/register';
  static const String logout = 'User/logout';

  // futsal endpoints
  static const String futsal = 'FutsalGround';
  static const String trendingFutsal = 'FutsalGround/trending';
  static const String topReviewedFutsal = 'FutsalGround/top-reviewed';
  static const String favoritesFutsal = 'FutsalGround/favourites';

  // user info
  static const String userInfo = 'User/manage/info';

  //image endpoint
  static const String uploadImage = 'images/upload/single';

  // bookings
  static const String bookings = 'Booking';

  //reviews
  static const String reviews = 'Reviews'; //get adn post reviews
  static String groundReviews(String groundId) => 'Reviews/Ground/$groundId';
}
