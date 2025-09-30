class UpdateUserModel {
  final String newEmail;
  final String newPassword;
  final String oldPassword;
  final int profileImageId;
  final String username;
  final String phoneNumber;

  UpdateUserModel({
    required this.newEmail,
    required this.newPassword,
    required this.oldPassword,
    required this.profileImageId,
    required this.username,
    required this.phoneNumber,
  });

  factory UpdateUserModel.fromJson(Map<String, dynamic> json) {
    return UpdateUserModel(
      newEmail: json['newEmail'] as String,
      newPassword: json['newPassword'] as String,
      oldPassword: json['oldPassword'] as String,
      profileImageId: json['profileImageId'] as int,
      username: json['username'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newEmail': newEmail,
      'newPassword': newPassword,
      'oldPassword': oldPassword,
      'profileImageId': profileImageId,
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'UpdateUserModel(newEmail: $newEmail, newPassword: $newPassword, oldPassword: $oldPassword, profileImageId: $profileImageId, username: $username, phoneNumber: $phoneNumber)';
  }
}
