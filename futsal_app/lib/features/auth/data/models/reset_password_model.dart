class ResetPasswordRequest {
  final String email;
  final String resetCode;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.resetCode,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'resetCode': resetCode,
      'newPassword': newPassword,
    };
  }
}

class VerifyResetCodeRequest {
  final String email;
  final String resetCode;

  VerifyResetCodeRequest({
    required this.email,
    required this.resetCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'resetCode': resetCode,
    };
  }
}

class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String? ?? 'Password reset successful',
    );
  }
}
