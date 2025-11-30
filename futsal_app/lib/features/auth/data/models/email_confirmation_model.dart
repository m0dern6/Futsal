class ResendConfirmationEmailRequest {
  final String email;

  ResendConfirmationEmailRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class EmailConfirmationResponse {
  final String message;

  EmailConfirmationResponse({required this.message});

  factory EmailConfirmationResponse.fromJson(Map<String, dynamic> json) {
    return EmailConfirmationResponse(
      message: json['message'] as String? ?? 'Email confirmation successful',
    );
  }
}
