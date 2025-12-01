import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/dimension.dart';
import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_state.dart';
import 'change_password.dart';

const Color kPrimaryGreenLight = Color(0xFF00C853);
const Color kPrimaryGreenDark = Color(0xFF00A843);
const Color kBgGrey = Color(0xFFF5F5F5);

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: kBgGrey,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(16),
          vertical: Dimension.height(8),
        ),
        children: [
          _SectionHeader('Security'),
          _ListTile(
            leading: Icons.shield_outlined,
            title: 'Two-Factor Authentication',
            subtitle: 'Protect your account with an extra step',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to 2FA management
            },
          ),
          SizedBox(height: Dimension.height(8)),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              bool emailVerified = false;
              if (state is ProfileLoaded) {
                emailVerified = state.userInfo.isEmailConfirmed;
              }
              return _ListTile(
                leading: Icons.email_outlined,
                title: 'Email Verification',
                subtitle: emailVerified ? 'Verified' : 'Not verified',
                trailing: _Chip(emailVerified ? 'Verified' : 'Verify'),
                onTap: emailVerified
                    ? null
                    : () {
                        // TODO: Start email verification flow
                      },
              );
            },
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              bool phoneVerified = false;
              if (state is ProfileLoaded) {
                phoneVerified = state.userInfo.isPhoneNumberConfirmed;
              }
              return _ListTile(
                leading: Icons.phone_outlined,
                title: 'Phone Verification',
                subtitle: phoneVerified ? 'Verified' : 'Not verified',
                trailing: _Chip(phoneVerified ? 'Verified' : 'Verify'),
                onTap: phoneVerified
                    ? null
                    : () {
                        // TODO: Start phone verification flow
                      },
              );
            },
          ),
          SizedBox(height: Dimension.height(16)),
          _SectionHeader('Account'),
          _ListTile(
            leading: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password regularly',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Dimension.width(4),
        bottom: Dimension.height(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Dimension.font(12),
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ListTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimension.width(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(12),
          vertical: Dimension.height(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimension.width(12)),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: Dimension.width(36),
              height: Dimension.width(36),
              decoration: BoxDecoration(
                color: kPrimaryGreenLight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(leading, color: kPrimaryGreenDark),
            ),
            SizedBox(width: Dimension.width(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Dimension.font(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: Dimension.height(4)),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: Dimension.font(12),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimension.width(10),
        vertical: Dimension.height(6),
      ),
      decoration: BoxDecoration(
        color: kPrimaryGreenLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Dimension.width(20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Dimension.font(11),
          fontWeight: FontWeight.w700,
          color: kPrimaryGreenDark,
        ),
      ),
    );
  }
}
