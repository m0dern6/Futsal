class ApiConst {
  static const String baseUrl = 'http://144.126.252.228:8080/';

  //auth endpoints
  static const String login = 'User/login';
  static const String refresh = 'User/refresh';
  static const String register = 'User/register';
  static const String logout = 'User/logout';
  static const String loginGoogle = 'User/login/google';
  static const String authGoogleCallback = 'User/auth/google/callback';

  // Email confirmation endpoints
  static const String confirmEmail = 'User/confirmEmail';
  static const String resendConfirmationEmail = 'User/resendConfirmationEmail';

  // Password reset endpoints
  static const String forgotPassword = 'User/forgotPassword';
  static const String resetPassword = 'User/resetPassword';
  static const String verifyResetCode = 'User/verifyResetCode';

  // Account management endpoints
  static const String deactivateAccount = 'User/manage/deactivate';
  static const String sendRevalidateEmail = 'User/manage/sendRevalidateEmail';
  static const String revalidateAccount = 'User/manage/revalidate';
  static const String setup2fa = 'User/manage/setup2fa';
  static const String manage2fa = 'User/manage/2fa';

  // Fixed futsal ground endpoints (removed leading slash)
  static const String futsalGround = 'FutsalGround';
  static String futsalDetails(String id) => 'FutsalGround/$id';
  static const String trendingGround = 'FutsalGround/trending';
  static const String topReviewGround = 'FutsalGround/top-reviewed';
  static const String favorites = 'FutsalGround/favourites';
  static String addFavorite(String groundId) =>
      'FutsalGround/favourite/$groundId';

  // review endpoints
  static String reviews =
      'Reviews'; // get all review of current user with pagination(Get) && also used to create a new review(Post)
  static String getReviewsById(String groundId) =>
      'Reviews/Ground/$groundId'; //retrieve(Get) reviews for a specific ground
  static String individualReviews(String reviewId) =>
      'Reviews/$reviewId'; //retrieves(Get), updates(Put) and delete(Delete) a existing review by id

  // Other endpoints
  static const String uploadImage = 'images/upload/single';
  static const String userInfo = 'User/manage/info';
  static const String bookFutsal = 'Booking';
}
