import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/view/bookings/bookings.dart';
import '../../core/dimension.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_state.dart';
import '../auth/login.dart';
import '../edit_profile/edit_profile.dart';
import '../settings/settings.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';
import 'data/model/user_info_model.dart';

const Color kPrimaryGreenLight = Color(0xFF00C853);
const Color kPrimaryGreenDark = Color(0xFF00A843);
const Color kBgGrey = Color(0xFFF5F5F5);

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: kBgGrey,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreenLight),
              ),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: Dimension.width(64),
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: Dimension.height(16)),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      fontSize: Dimension.font(16),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Dimension.height(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimension.width(32),
                    ),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        fontSize: Dimension.font(13),
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: Dimension.height(16)),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(const LoadUserInfo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreenLight,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(state.userInfo);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileContent(UserInfoModel userInfo) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(userInfo),
            SizedBox(height: Dimension.height(20)),
            _buildProfileCard(userInfo),
            SizedBox(height: Dimension.height(18)),
            _buildMenuItems(userInfo),
            SizedBox(height: Dimension.height(32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserInfoModel userInfo) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        Dimension.width(20),
        Dimension.height(20),
        Dimension.width(20),
        Dimension.height(24),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryGreenLight, kPrimaryGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimension.width(28)),
          bottomRight: Radius.circular(Dimension.width(28)),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreenDark.withOpacity(0.25),
            blurRadius: Dimension.width(16),
            offset: Offset(0, Dimension.height(6)),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: Dimension.width(56),
            height: Dimension.width(56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // border: Border.all(
              //   color: Colors.white.withOpacity(0.35),
              //   width: Dimension.width(2),
              // ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: Dimension.width(10),
                  offset: Offset(0, Dimension.height(4)),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
          ),
          SizedBox(width: Dimension.width(14)),
          Expanded(
            child: Text(
              'Futsal Pay',
              style: TextStyle(
                fontSize: Dimension.font(26),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimension.width(14),
              vertical: Dimension.height(8),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(Dimension.width(20)),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: Dimension.font(14),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserInfoModel userInfo) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
      padding: EdgeInsets.all(Dimension.width(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimension.width(20)),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: Dimension.width(14),
            offset: Offset(0, Dimension.height(6)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: Dimension.width(80),
            height: Dimension.width(80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryGreenLight, kPrimaryGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: Dimension.width(2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: userInfo.fullImageUrl != null
                ? Image.network(
                    userInfo.fullImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.person,
                      size: Dimension.width(48),
                      color: Colors.white.withOpacity(0.85),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: Dimension.width(48),
                    color: Colors.white.withOpacity(0.85),
                  ),
          ),
          SizedBox(height: Dimension.height(14)),
          Text(
            userInfo.username,
            style: TextStyle(
              fontSize: Dimension.font(22),
              fontWeight: FontWeight.w700,
              color: kPrimaryGreenDark,
            ),
          ),
          SizedBox(height: Dimension.height(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  userInfo.email,
                  style: TextStyle(
                    fontSize: Dimension.font(14),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (userInfo.isEmailConfirmed) ...[
                SizedBox(width: Dimension.width(6)),
                Icon(
                  Icons.verified,
                  size: Dimension.width(16),
                  color: kPrimaryGreenLight,
                ),
              ],
            ],
          ),
          if (userInfo.phoneNumber != null &&
              userInfo.phoneNumber!.isNotEmpty) ...[
            SizedBox(height: Dimension.height(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone,
                  size: Dimension.width(14),
                  color: Colors.grey[600],
                ),
                SizedBox(width: Dimension.width(4)),
                Text(
                  userInfo.phoneNumber!,
                  style: TextStyle(
                    fontSize: Dimension.font(13),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (userInfo.isPhoneNumberConfirmed) ...[
                  SizedBox(width: Dimension.width(4)),
                  Icon(
                    Icons.verified,
                    size: Dimension.width(14),
                    color: kPrimaryGreenLight,
                  ),
                ],
              ],
            ),
          ],
          SizedBox(height: Dimension.height(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'Bookings',
                value: '12',
                onViewTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingsScreen(),
                    ),
                  );
                },
              ),
              Container(
                width: Dimension.width(1),
                height: Dimension.height(40),
                color: Colors.black.withOpacity(0.06),
              ),
              _StatItem(label: 'Favorites', value: '8'),
              Container(
                width: Dimension.width(1),
                height: Dimension.height(40),
                color: Colors.black.withOpacity(0.06),
              ),
              _StatItem(
                label: 'Reviews',
                value: '5',
                onViewTap: () {
                  // TODO: Navigate to reviews list
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(UserInfoModel userInfo) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimension.width(20)),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(userInfo: userInfo),
                ),
              );
            },
          ),
          SizedBox(height: Dimension.height(10)),
          _MenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          SizedBox(height: Dimension.height(10)),
          _MenuItem(
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          SizedBox(height: Dimension.height(10)),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
          ),
          SizedBox(height: Dimension.height(10)),
          _MenuItem(icon: Icons.info_outline, title: 'About', onTap: () {}),
          SizedBox(height: Dimension.height(18)),
          _MenuItem(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimension.width(20)),
        ),
        title: Row(
          children: [
            Container(
              width: Dimension.width(40),
              height: Dimension.width(40),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout,
                color: Colors.red,
                size: Dimension.width(22),
              ),
            ),
            SizedBox(width: Dimension.width(12)),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: Dimension.font(20),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: Dimension.font(15),
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Dimension.font(15),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: ElevatedButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const LogoutRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(10)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(20),
                  vertical: Dimension.height(10),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: Dimension.font(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onViewTap;
  const _StatItem({required this.label, required this.value, this.onViewTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: Dimension.font(20),
            fontWeight: FontWeight.w800,
            color: kPrimaryGreenDark,
          ),
        ),
        SizedBox(height: Dimension.height(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: Dimension.font(13),
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onViewTap != null) ...[
          SizedBox(height: Dimension.height(4)),
          TextButton(
            onPressed: onViewTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(Dimension.width(40), Dimension.height(20)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View',
              style: TextStyle(
                fontSize: Dimension.font(11),
                fontWeight: FontWeight.w700,
                color: kPrimaryGreenDark,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : kPrimaryGreenDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimension.width(14)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(16),
          vertical: Dimension.height(10),
        ),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(Dimension.width(14)),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.18)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: Dimension.width(10),
              offset: Offset(0, Dimension.height(4)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: Dimension.width(32),
              height: Dimension.width(32),
              decoration: BoxDecoration(
                gradient: isDestructive
                    ? null
                    : const LinearGradient(
                        colors: [kPrimaryGreenLight, kPrimaryGreenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDestructive ? Colors.red.withOpacity(0.12) : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Dimension.width(22),
                color: isDestructive ? Colors.red : Colors.white,
              ),
            ),
            SizedBox(width: Dimension.width(14)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Dimension.font(15),
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: Dimension.width(22),
              color: color.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}
