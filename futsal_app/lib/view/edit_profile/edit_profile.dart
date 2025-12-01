import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/view/profile/bloc/profile_bloc.dart';
import 'package:ui/view/profile/bloc/profile_event.dart';
import '../../core/dimension.dart';
import '../profile/data/model/user_info_model.dart';
import '../profile/data/repository/profile_repository.dart';

const Color kPrimaryGreenLight = Color(0xFF00C853);
const Color kPrimaryGreenDark = Color(0xFF00A843);
const Color kBgGrey = Color(0xFFF5F5F5);

class EditProfile extends StatefulWidget {
  final UserInfoModel userInfo;

  const EditProfile({super.key, required this.userInfo});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _showEmailWarning = true;
  bool _showPhoneWarning = true;
  bool _isLoading = false;
  String _originalUsername = '';

  @override
  void initState() {
    super.initState();
    _originalUsername = widget.userInfo.username;
    _usernameController.text = widget.userInfo.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        // Check if the file is JPEG
        if (image.path.toLowerCase().endsWith('.jpg') ||
            image.path.toLowerCase().endsWith('.jpeg')) {
          setState(() {
            _selectedImage = File(image.path);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please select only JPEG images'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(10)),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimension.width(10)),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        // Check if the file is JPEG
        if (image.path.toLowerCase().endsWith('.jpg') ||
            image.path.toLowerCase().endsWith('.jpeg')) {
          setState(() {
            _selectedImage = File(image.path);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please select only JPEG images'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimension.width(10)),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimension.width(10)),
            ),
          ),
        );
      }
    }
  }

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimension.width(20)),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(Dimension.width(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Dimension.width(40),
              height: Dimension.height(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimension.width(2)),
              ),
            ),
            SizedBox(height: Dimension.height(20)),
            Text(
              'Choose Profile Photo',
              style: TextStyle(
                fontSize: Dimension.font(18),
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: Dimension.height(20)),
            _ImagePickerOption(
              icon: Icons.camera_alt,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            SizedBox(height: Dimension.height(12)),
            _ImagePickerOption(
              icon: Icons.photo_library,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            SizedBox(height: Dimension.height(20)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final repository = ProfileRepository();
      int? uploadedImageId;

      // Upload image if selected
      if (_selectedImage != null) {
        uploadedImageId = await repository.uploadImage(_selectedImage!);
      }

      // Build selective update body
      final Map<String, dynamic> updates = {};
      if (_usernameController.text.trim() != _originalUsername) {
        updates['username'] = _usernameController.text.trim();
      }
      if (uploadedImageId != null) {
        updates['profileImageId'] = uploadedImageId;
      }

      // Update if there are changes
      if (updates.isNotEmpty) {
        await repository.updateUserInfo(updates);
      }

      // Success - refresh profile and pop
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadUserInfo());
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimension.width(10)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Scaffold(
      backgroundColor: kBgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: EdgeInsets.fromLTRB(
                Dimension.width(20),
                Dimension.height(16),
                Dimension.width(20),
                Dimension.height(16),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryGreenLight, kPrimaryGreenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGreenDark.withOpacity(0.2),
                    blurRadius: Dimension.width(12),
                    offset: Offset(0, Dimension.height(4)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(Dimension.width(8)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          Dimension.width(10),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: Dimension.width(24),
                      ),
                    ),
                  ),
                  SizedBox(width: Dimension.width(16)),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: Dimension.font(22),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimension.width(20)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // SizedBox(height: Dimension.height(20)),

                      // Verification Warnings
                      if (!widget.userInfo.isEmailConfirmed &&
                          _showEmailWarning)
                        _VerificationWarning(
                          icon: Icons.email_outlined,
                          message:
                              'Your email is not verified. Go to settings to verify.',
                          onDismiss: () {
                            setState(() {
                              _showEmailWarning = false;
                            });
                          },
                        ),
                      if (!widget.userInfo.isEmailConfirmed &&
                          _showEmailWarning)
                        SizedBox(height: Dimension.height(12)),

                      if (!widget.userInfo.isPhoneNumberConfirmed &&
                          _showPhoneWarning)
                        _VerificationWarning(
                          icon: Icons.phone_outlined,
                          message:
                              'Your phone number is not verified. Go to settings to verify.',
                          onDismiss: () {
                            setState(() {
                              _showPhoneWarning = false;
                            });
                          },
                        ),
                      if (!widget.userInfo.isPhoneNumberConfirmed &&
                          _showPhoneWarning)
                        SizedBox(height: Dimension.height(12)),

                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: Dimension.width(120),
                              height: Dimension.width(120),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    kPrimaryGreenLight,
                                    kPrimaryGreenDark,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: Dimension.width(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimaryGreenDark.withOpacity(0.3),
                                    blurRadius: Dimension.width(20),
                                    offset: Offset(0, Dimension.height(8)),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: Dimension.width(60),
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: Dimension.width(40),
                                  height: Dimension.width(40),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        kPrimaryGreenLight,
                                        kPrimaryGreenDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: Dimension.width(3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: Dimension.width(8),
                                        offset: Offset(0, Dimension.height(2)),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: Dimension.width(20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Dimension.height(12)),

                      Text(
                        'Tap to change profile picture',
                        style: TextStyle(
                          fontSize: Dimension.font(13),
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: Dimension.height(40)),

                      // Username Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            Dimension.width(16),
                          ),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: Dimension.width(12),
                              offset: Offset(0, Dimension.height(4)),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(
                            fontSize: Dimension.font(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: Dimension.font(14),
                              fontWeight: FontWeight.w500,
                            ),
                            floatingLabelStyle: TextStyle(
                              color: kPrimaryGreenDark,
                              fontSize: Dimension.font(14),
                              fontWeight: FontWeight.w700,
                            ),
                            hintText: 'Enter your username',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: Dimension.font(15),
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Container(
                              margin: EdgeInsets.only(
                                right: Dimension.width(12),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: kPrimaryGreenDark,
                                size: Dimension.width(24),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: Dimension.width(20),
                              vertical: Dimension.height(18),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              borderSide: BorderSide(
                                color: kPrimaryGreenLight,
                                width: Dimension.width(2),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              borderSide: BorderSide(
                                color: Colors.red.withOpacity(0.5),
                                width: Dimension.width(1.5),
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: Dimension.width(2),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            final trimmed = value.trim();
                            if (trimmed.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            // Must be a single word with letters only (no digits or symbols)
                            final regex = RegExp(r'^[A-Za-z]+$');
                            if (!regex.hasMatch(trimmed)) {
                              return 'Username must contain letters only (no spaces, digits, or symbols)';
                            }
                            return null;
                          },
                        ),
                      ),

                      SizedBox(height: Dimension.height(20)),

                      // Info Card
                      Container(
                        padding: EdgeInsets.all(Dimension.width(16)),
                        decoration: BoxDecoration(
                          color: kPrimaryGreenLight.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                            Dimension.width(14),
                          ),
                          border: Border.all(
                            color: kPrimaryGreenLight.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: kPrimaryGreenDark,
                              size: Dimension.width(22),
                            ),
                            SizedBox(width: Dimension.width(12)),
                            Expanded(
                              child: Text(
                                'Username must be a single word with letters only — no spaces, digits, or symbols (e.g., . _ ; ,).',
                                style: TextStyle(
                                  fontSize: Dimension.font(13),
                                  color: kPrimaryGreenDark,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Dimension.height(40)),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: Dimension.height(54),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimaryGreenLight, kPrimaryGreenDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              Dimension.width(16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryGreenDark.withOpacity(0.4),
                                blurRadius: Dimension.width(12),
                                offset: Offset(0, Dimension.height(6)),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimension.width(16),
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: Dimension.height(24),
                                    width: Dimension.width(24),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: Dimension.width(22),
                                      ),
                                      SizedBox(width: Dimension.width(10)),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontSize: Dimension.font(16),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: Dimension.height(20)),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: Dimension.height(54),
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: Dimension.width(2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Dimension.width(16),
                              ),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: Dimension.font(16),
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimension.width(14)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimension.width(16),
          vertical: Dimension.height(14),
        ),
        decoration: BoxDecoration(
          color: kPrimaryGreenLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Dimension.width(14)),
          border: Border.all(color: kPrimaryGreenLight.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: Dimension.width(40),
              height: Dimension.width(40),
              decoration: BoxDecoration(
                color: kPrimaryGreenDark.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: kPrimaryGreenDark,
                size: Dimension.width(22),
              ),
            ),
            SizedBox(width: Dimension.width(16)),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimension.font(15),
                fontWeight: FontWeight.w600,
                color: kPrimaryGreenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationWarning extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onDismiss;

  const _VerificationWarning({
    required this.icon,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimension.width(2)),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimension.width(14)),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: Dimension.width(26),
            height: Dimension.width(26),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.orange[800],
              size: Dimension.width(14),
            ),
          ),
          SizedBox(width: Dimension.width(12)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: Dimension.font(10),
                color: Colors.orange[900],
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: Dimension.width(8)),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: EdgeInsets.all(Dimension.width(4)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.orange[800],
                size: Dimension.width(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
