import 'package:equatable/equatable.dart';

class UserInfoModel extends Equatable {
  final String id;
  final String email;
  final bool isEmailConfirmed;
  final String? profileImageUrl;
  final String username;
  final String? phoneNumber;
  final bool isPhoneNumberConfirmed;

  const UserInfoModel({
    required this.id,
    required this.email,
    required this.isEmailConfirmed,
    this.profileImageUrl,
    required this.username,
    this.phoneNumber,
    required this.isPhoneNumberConfirmed,
  });

  // Get full image URL with base URL prepended
  String? get fullImageUrl {
    if (profileImageUrl == null || profileImageUrl!.isEmpty) {
      return null;
    }
    // If it's already a full URL, return as is
    if (profileImageUrl!.startsWith('http')) {
      return profileImageUrl;
    }
    // Otherwise prepend base URL
    return 'http://144.126.252.228:8080$profileImageUrl';
  }

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

  @override
  List<Object?> get props => [
    id,
    email,
    isEmailConfirmed,
    profileImageUrl,
    username,
    phoneNumber,
    isPhoneNumberConfirmed,
  ];
}
