class UserInfoModel {
  final String id;
  final String email;
  final bool isEmailConfirmed;
  final String? profileImageUrl;
  final String username;
  final String? phoneNumber;
  final bool isPhoneNumberConfirmed;

  UserInfoModel({
    required this.id,
    required this.email,
    required this.isEmailConfirmed,
    this.profileImageUrl,
    required this.username,
    this.phoneNumber,
    required this.isPhoneNumberConfirmed,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] as String,
      email: json['email'] as String,
      isEmailConfirmed: json['isEmailConfirmed'] as bool,
      profileImageUrl: json['profileImageUrl'] as String?,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      isPhoneNumberConfirmed: json['isPhoneNumberConfirmed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'isEmailConfirmed': isEmailConfirmed,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'phoneNumber': phoneNumber,
      'isPhoneNumberConfirmed': isPhoneNumberConfirmed,
    };
  }
}
