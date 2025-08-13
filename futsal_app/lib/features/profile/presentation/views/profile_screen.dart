import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: const Color(0xff03340d).withOpacity(0.6),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Dimension.font(16), // reduced
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<LogoutBloc, LogoutState>(
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.go('/login');
          } else if (state is LogoutFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logout failed: {state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimension.width(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: Dimension.height(10)),
              _buildProfileHeader(context),
              SizedBox(height: Dimension.height(15)),
              _buildQuickActionButtons(context),
              SizedBox(height: Dimension.height(15)),
              _buildSettingsSection(context),
              SizedBox(height: Dimension.height(10)),
              _buildLogoutButton(context),
              SizedBox(height: Dimension.height(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        // Profile Image with Edit Icon at top right, no container
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: Dimension.width(40), // reduced size
              backgroundColor: const Color(0xff1A8931),
              child: Icon(
                Icons.person,
                size: Dimension.font(45), // reduced size
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: Dimension.font(18),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimension.height(8)),

        // Name
        Text(
          'John Doe', // Replace with actual user name
          style: TextStyle(
            color: Colors.white,
            fontSize: Dimension.font(16), // reduced
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: Dimension.height(3)),

        // Email
        Text(
          'john.doe@example.com', // Replace with actual user email
          style: TextStyle(
            color: const Color(0xff91A693),
            fontSize: Dimension.font(12), // reduced
          ),
        ),
        SizedBox(height: Dimension.height(10)),

        // Edit Profile Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff156F1F),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: Dimension.width(18),
              vertical: Dimension.height(7),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimension.width(18)),
            ),
            elevation: 2,
          ),
          onPressed: () {
            // Navigate to edit profile screen
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: Dimension.font(12)),
              SizedBox(width: Dimension.width(5)),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: Dimension.font(11),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimension.width(8)),
      decoration: BoxDecoration(
        color: const Color(0xff013109).withOpacity(0.5),
        borderRadius: BorderRadius.circular(Dimension.width(10)),
        border: Border.all(
          color: const Color(0xff04340B),
          width: Dimension.width(1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: const Color(0xff91A693),
              fontSize: Dimension.font(12),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Dimension.height(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionCard(
                icon: CupertinoIcons.tickets_fill,
                title: 'My Bookings',
                color: const Color(0xff1A8931),
                onTap: () => context.go('/bookings'),
              ),
              _buildQuickActionCard(
                icon: CupertinoIcons.creditcard_fill,
                title: 'Transactions',
                color: const Color(0xff0F7687),
                onTap: () {
                  // Navigate to transactions screen
                },
              ),
              _buildQuickActionCard(
                icon: CupertinoIcons.star_fill,
                title: 'My Reviews',
                color: const Color(0xffB65938),
                onTap: () {
                  // Navigate to reviews screen
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Dimension.width(70),
        padding: EdgeInsets.symmetric(
          vertical: Dimension.height(8),
          horizontal: Dimension.width(4),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(Dimension.width(8)),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: Dimension.width(1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: Dimension.font(18)),
            SizedBox(height: Dimension.height(4)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: Dimension.font(8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff013109).withOpacity(0.3),
        borderRadius: BorderRadius.circular(Dimension.width(8)),
        border: Border.all(
          color: const Color(0xff04340B),
          width: Dimension.width(0.5),
        ),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: CupertinoIcons.settings_solid,
            title: 'Settings',
            onTap: () {
              // Navigate to settings screen
            },
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.globe,
            title: 'Language',
            onTap: () {
              // Navigate to language selection
            },
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.moon_fill,
            title: 'Theme',
            onTap: () {
              // Navigate to theme selection
            },
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.bell_fill,
            title: 'Notifications',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.shield_fill,
            title: 'Privacy & Security',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.question_circle_fill,
            title: 'Help & Support',
            onTap: () {
              // Navigate to help center
            },
          ),
          // _buildSettingsTile(
          //   icon: CupertinoIcons.info_circle_fill,
          //   title: 'About',
          //   onTap: () {
          //     // Navigate to about screen
          //   },
          //   showDivider: false,
          // ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: const Color(0xff91A693),
            size: Dimension.font(14),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: Dimension.font(11),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            CupertinoIcons.chevron_forward,
            color: const Color(0xff91A693),
            size: Dimension.font(12),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: Dimension.width(8)),
          minLeadingWidth: 0,
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimension.width(8)),
            child: Divider(
              color: const Color(0xff04340B),
              height: Dimension.height(1),
            ),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocBuilder<LogoutBloc, LogoutState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.15),
              foregroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(vertical: Dimension.height(8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimension.width(8)),
                side: const BorderSide(color: Colors.redAccent),
              ),
              elevation: 0,
            ),
            onPressed: state is LogoutLoading
                ? null
                : () => _showLogoutConfirmDialog(context),
            icon: state is LogoutLoading
                ? SizedBox(
                    width: Dimension.width(12),
                    height: Dimension.height(12),
                    child: const CircularProgressIndicator(
                      color: Colors.redAccent,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.logout, size: Dimension.font(12)),
            label: Text(
              state is LogoutLoading ? 'Logging out...' : 'Logout',
              style: TextStyle(
                fontSize: Dimension.font(11),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff013109),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimension.width(16)),
            side: BorderSide(
              color: const Color(0xff04340B),
              width: Dimension.width(1),
            ),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Dimension.font(18),
            ),
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(
              color: const Color(0xff91A693),
              fontSize: Dimension.font(14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xff91A693),
                  fontSize: Dimension.font(14),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(8)),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<LogoutBloc>().add(LogoutButtonPressed());
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: Dimension.font(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
