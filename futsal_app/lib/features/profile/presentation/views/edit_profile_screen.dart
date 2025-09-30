import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/core/const/api_const.dart';
import 'package:futsalpay/features/profile/data/repository/profile_repository.dart';
import 'package:futsalpay/shared/upload_image/data/repository/upload_image_repository.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/edit_profile_bloc/edit_profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  File? _pickedImage;
  int? _uploadedImageId;
  bool _isImageUploading = false;

  late final UploadImageRepository _uploadRepo;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _hasChanges = false;
  Map<String, String> _originalData = {};

  @override
  void initState() {
    super.initState();
    _uploadRepo = UploadImageRepository(ApiService());

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();

    // Listen for changes
    _usernameCtrl.addListener(_onFormChanged);
    _emailCtrl.addListener(_onFormChanged);
    _phoneCtrl.addListener(_onFormChanged);

    // Pre-fill user data
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadUserData());
  }

  void _onFormChanged() {
    setState(() {
      _hasChanges =
          _usernameCtrl.text != _originalData['username'] ||
          _emailCtrl.text != _originalData['email'] ||
          _phoneCtrl.text != _originalData['phone'] ||
          _pickedImage != null;
    });
  }

  void _preloadUserData() {
    final userInfoBloc = context.read<UserInfoBloc>();
    final state = userInfoBloc.state;
    if (state is UserInfoLoaded) {
      final user = state.userInfo;
      _usernameCtrl.text = user.username;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phoneNumber ?? '';

      // Store original data for change detection
      _originalData = {
        'username': user.username,
        'email': user.email,
        'phone': user.phoneNumber ?? '',
      };
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => EditProfileBloc(ProfileRepository(ApiService())),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(theme, context),
            body: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildBody(theme, context),
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, BuildContext context) {
    return AppBar(
      title: Text(
        'Edit Profile',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: Dimension.font(18),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: () => _saveProfile(context),
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: Dimension.font(16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, BuildContext context) {
    return BlocListener<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh user info
          context.read<UserInfoBloc>().add(LoadUserInfo());
          Navigator.of(context).pop();
        } else if (state is EditProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.all(Dimension.width(20)),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: Dimension.height(20)),
                _buildProfileImage(theme),
                SizedBox(height: Dimension.height(30)),
                _buildInputField(
                  controller: _usernameCtrl,
                  focusNode: _usernameFocus,
                  label: 'Username',
                  icon: Icons.person_outline,
                  theme: theme,
                ),
                SizedBox(height: Dimension.height(20)),
                _buildInputField(
                  controller: _emailCtrl,
                  focusNode: _emailFocus,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  theme: theme,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: Dimension.height(20)),
                _buildInputField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  theme: theme,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: Dimension.height(40)),
                _buildSaveButton(theme, context),
                SizedBox(height: Dimension.height(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(ThemeData theme) {
    return BlocBuilder<UserInfoBloc, UserInfoState>(
      builder: (context, state) {
        final user = state is UserInfoLoaded ? state.userInfo : null;

        return Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: Dimension.width(60),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: _pickedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimension.width(60),
                        ),
                        child: Image.file(
                          _pickedImage!,
                          width: Dimension.width(120),
                          height: Dimension.width(120),
                          fit: BoxFit.cover,
                        ),
                      )
                    : user?.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Dimension.width(60),
                        ),
                        child: Image.network(
                          '${ApiConst.baseUrl}${user!.profileImageUrl}',
                          width: Dimension.width(120),
                          height: Dimension.width(120),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: Dimension.font(60),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: Dimension.font(60),
                        color: theme.colorScheme.primary,
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(Dimension.width(8)),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                      size: Dimension.font(20),
                    ),
                  ),
                ),
              ),
              if (_isImageUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: Dimension.font(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Dimension.height(8)),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: Dimension.font(16),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: Dimension.font(14),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimension.width(16),
              vertical: Dimension.height(12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.width(14)),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.width(14)),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimension.width(14)),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (label == 'Email' && value != null && value.isNotEmpty) {
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme, BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        if (state is EditProfileLoading) {
          return Container(
            width: double.infinity,
            height: Dimension.height(50),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(Dimension.width(14)),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        return ElevatedButton(
          onPressed: _hasChanges ? () => _saveProfile(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasChanges
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.5),
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: Dimension.height(16)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimension.width(14)),
            ),
            elevation: 0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Save Changes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimension.font(16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _onFormChanged(); // Trigger change detection
      });

      // Upload image immediately
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_pickedImage == null) return;

    setState(() {
      _isImageUploading = true;
    });

    try {
      final uploadResult = await _uploadRepo.upload(_pickedImage!);
      setState(() {
        _uploadedImageId = uploadResult.id;
        _isImageUploading = false;
      });
    } catch (e) {
      setState(() {
        _isImageUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveProfile(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final userInfoBloc = context.read<UserInfoBloc>();
    final state = userInfoBloc.state;

    if (state is UserInfoLoaded) {
      final currentUser = state.userInfo;

      // Only include changed fields
      String? newUsername;
      String? newEmail;
      String? newPhone;

      if (_usernameCtrl.text != currentUser.username) {
        newUsername = _usernameCtrl.text;
      }

      if (_emailCtrl.text != currentUser.email) {
        newEmail = _emailCtrl.text;
      }

      if (_phoneCtrl.text != (currentUser.phoneNumber ?? '')) {
        newPhone = _phoneCtrl.text;
      }

      context.read<EditProfileBloc>().add(
        EditProfileSubmitted(
          username: newUsername,
          email: newEmail,
          phoneNumber: newPhone,
          profileImageId: _uploadedImageId,
        ),
      );
    }
  }
}
