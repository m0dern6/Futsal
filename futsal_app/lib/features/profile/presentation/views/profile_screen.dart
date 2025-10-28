import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:futsalpay/core/theme/theme_notifier.dart';
import 'my_reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: Dimension.font(16), // reduced
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimension.width(16)),
        child: _buildLogoutButton(context),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: Dimension.height(10)),
                _buildProfileHeader(context),
                SizedBox(height: Dimension.height(20)),
                _buildQuickActionButtons(context),
                SizedBox(height: Dimension.height(20)),
                _buildSettingsSection(context),
                SizedBox(
                  height: Dimension.height(120),
                ), // space for FAB & nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserInfoBloc, UserInfoState>(
      builder: (context, state) {
        final user = state is UserInfoLoaded ? state.userInfo : null;
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: Dimension.width(80),
                  height: Dimension.width(80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimension.width(100)),
                    child: Image.network(
                      '${ApiConst.baseUrl}${user?.profileImageUrl}',

                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: Dimension.font(42),
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit,
                      size: Dimension.font(12),
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimension.height(10)),
            Text(
              user?.username ?? 'Guest',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: Dimension.height(4)),
            Text(
              user?.email ?? 'nomail@example.com',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(.65),
              ),
            ),
            SizedBox(height: Dimension.height(12)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimension.width(20),
                  vertical: Dimension.height(8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(30)),
                ),
              ),
              onPressed: () => context.go('/profile/edit-profile'),
              icon: Icon(Icons.edit, size: Dimension.font(14)),
              label: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: Dimension.font(11.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(Dimension.width(14)),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimension.width(20)),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: Dimension.height(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickActionCard(
                context: context,
                icon: CupertinoIcons.tickets_fill,
                title: 'My Bookings',
                color: theme.colorScheme.primary,
                onTap: () => context.push('/bookings'),
              ),
              _buildQuickActionCard(
                context: context,
                icon: CupertinoIcons.creditcard_fill,
                title: 'My Payments',
                color: theme.colorScheme.tertiary,
                onTap: () {},
              ),
              _buildQuickActionCard(
                context: context,
                icon: CupertinoIcons.star_fill,
                title: 'My Reviews',
                color: theme.colorScheme.secondary,
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => MyReviewsScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? color.withOpacity(.18) : color.withOpacity(.12);
    final border = color.withOpacity(.35);
    final textColor = theme.colorScheme.onSurface.withOpacity(.85);
    return InkWell(
      borderRadius: BorderRadius.circular(Dimension.width(16)),
      onTap: onTap,
      child: Container(
        width: Dimension.width(88),
        padding: EdgeInsets.symmetric(
          vertical: Dimension.height(10),
          horizontal: Dimension.width(6),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimension.width(16)),
          border: Border.all(color: border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: Dimension.font(18)),
            ),
            SizedBox(height: Dimension.height(8)),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: Dimension.font(9),
                color: textColor,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = context.watch<ThemeNotifier>();
    final isDark = notifier.mode == ThemeMode.dark;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(Dimension.width(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: CupertinoIcons.settings_solid,
            title: 'Settings',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.globe,
            title: 'Language',
            onTap: () {},
          ),
          // Theme toggle row
          SwitchListTile.adaptive(
            value: isDark,
            onChanged: (_) => notifier.toggle(),
            secondary: Icon(
              CupertinoIcons.moon_fill,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: Dimension.font(11),
                fontWeight: FontWeight.w500,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimension.width(8),
            ),
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.bell_fill,
            title: 'Notifications',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.shield_fill,
            title: 'Privacy & Security',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: CupertinoIcons.question_circle_fill,
            title: 'Help & Support',
            onTap: () {},
            showDivider: false,
          ),
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
          leading: Icon(icon, size: Dimension.font(16)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: Dimension.font(11),
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            CupertinoIcons.chevron_forward,
            size: Dimension.font(12),
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: Dimension.width(8)),
          minLeadingWidth: 0,
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimension.width(8)),
            child: const Divider(height: 0),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<LogoutBloc, LogoutState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              padding: EdgeInsets.symmetric(vertical: Dimension.height(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimension.width(16)),
              ),
              elevation: 2,
            ),
            onPressed: state is LogoutLoading
                ? null
                : () => _showLogoutConfirmDialog(context),
            icon: state is LogoutLoading
                ? SizedBox(
                    width: Dimension.width(14),
                    height: Dimension.height(14),
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.onErrorContainer,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.logout, size: Dimension.font(16)),
            label: Text(
              state is LogoutLoading ? 'Logging out...' : 'Logout',
              style: TextStyle(
                fontSize: Dimension.font(12),
                fontWeight: FontWeight.w700,
                letterSpacing: .3,
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
