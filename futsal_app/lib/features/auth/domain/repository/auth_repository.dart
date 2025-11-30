import 'package:futsalpay/features/auth/data/models/email_confirmation_model.dart';
import 'package:futsalpay/features/auth/data/models/forgot_password_model.dart';
import 'package:futsalpay/features/auth/data/models/login_model.dart';
import 'package:futsalpay/features/auth/data/models/register_model.dart';
import 'package:futsalpay/features/auth/data/models/reset_password_model.dart';

abstract class AuthRepository {
  // Basic auth
  Future<RegisterResponseModel> register(Map<String, dynamic> userData);
  Future<LoginResponseModel> login(String email, String password);
  Future<void> logout();
  Future<LoginResponseModel> refreshToken(String refreshToken);

  // Email confirmation
  Future<EmailConfirmationResponse> resendConfirmationEmail(String email);

  // Password reset
  Future<ForgotPasswordResponse> forgotPassword(String email);
  Future<void> verifyResetCode(String email, String resetCode);
  Future<ResetPasswordResponse> resetPassword(
    String email,
    String resetCode,
    String newPassword,
  );

  // Account management
  Future<void> deactivateAccount();
  Future<void> sendRevalidateEmail();
}
