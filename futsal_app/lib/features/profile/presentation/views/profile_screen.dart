import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1B2B), // Dark futsal-themed background
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildProfileMenu(context),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF7CFF6B),
          child: Icon(Icons.person, size: 60, color: Color(0xFF0B1B2B)),
          // backgroundImage: NetworkImage('URL_TO_USER_IMAGE'), // Uncomment to use a network image
        ),
        const SizedBox(height: 12),
        const Text(
          'John Doe', // Replace with user's name
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'john.doe@example.com', // Replace with user's email
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: CupertinoIcons.person_fill,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Navigate to Edit Profile Screen
            },
          ),
          _buildMenuTile(
            icon: CupertinoIcons.ticket_fill,
            title: 'My Bookings',
            onTap: () => context.go('/bookings'),
          ),
          _buildMenuTile(
            icon: CupertinoIcons.heart_fill,
            title: 'Favorites',
            onTap: () => context.go('/favorites'),
          ),
          _buildMenuTile(
            icon: CupertinoIcons.settings_solid,
            title: 'Settings',
            onTap: () {
              // TODO: Navigate to Settings Screen
            },
          ),
          _buildMenuTile(
            icon: CupertinoIcons.question_circle_fill,
            title: 'Help Center',
            onTap: () {
              // TODO: Navigate to Help Center Screen
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF7CFF6B)),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            CupertinoIcons.chevron_forward,
            color: Colors.white54,
            size: 20,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.white12, height: 1),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.1),
        foregroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.redAccent),
        ),
        elevation: 0,
      ),
      onPressed: () => _showLogoutConfirmDialog(context),
      icon: const Icon(Icons.logout),
      label: const Text(
        'Logout',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocBuilder<LogoutBloc, LogoutState>(
          builder: (context, state) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1C2A3A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CFF6B),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    context.read<LogoutBloc>().add(LogoutButtonPressed());
                    Navigator.of(dialogContext).pop();
                    if (state is LogoutSuccess) context.go('/login');
                  },
                  child: state is LogoutLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
