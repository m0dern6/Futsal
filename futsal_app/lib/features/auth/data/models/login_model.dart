class LoginResponseModel {
  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final String refreshToken;

  LoginResponseModel({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      tokenType: json['tokenType'],
      accessToken: json['accessToken'],
      expiresIn: json['expiresIn'],
      refreshToken: json['refreshToken'],
    );
  }
}
