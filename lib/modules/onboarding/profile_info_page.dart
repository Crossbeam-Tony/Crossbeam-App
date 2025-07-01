import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/onboarding_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/safe_avatar.dart';
import '../../config/theme_presets.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({Key? key}) : super(key: key);

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OnboardingProvider>();
      _firstNameController.text = provider.firstName;
      _lastNameController.text = provider.lastName;
      _bioController.text = provider.bio;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final storageService = StorageService();
        final url = await storageService.uploadAvatar(File(image.path));
        context.read<OnboardingProvider>().setProfileInfo(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              bio: _bioController.text,
              avatarUrl: url,
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currentTheme =
            getThemePresetBySlug(provider.themeSlug, provider.isDarkMode);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Header
                Text(
                  'Tell us about yourself',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help others get to know you better',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: currentTheme?.textColor.withOpacity(0.7) ??
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 20),

                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SafeAvatar(
                            radius: 40,
                            backgroundColor: currentTheme?.cardColor ??
                                Theme.of(context).colorScheme.surface,
                            imageUrl: provider.avatarUrl,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: currentTheme?.primaryColor ??
                                      Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickImage,
                        style: TextButton.styleFrom(
                          foregroundColor: currentTheme?.primaryColor,
                        ),
                        child: const Text('Change Photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Name Fields
                Text(
                  'Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _firstNameController,
                  style: TextStyle(color: currentTheme?.textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your first name',
                    prefixIcon: Icon(Icons.person,
                        size: 20, color: currentTheme?.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintStyle: TextStyle(
                        color: currentTheme?.textColor.withOpacity(0.5)),
                  ),
                  onChanged: (value) {
                    provider.setProfileInfo(
                      firstName: value,
                      lastName: _lastNameController.text,
                      bio: _bioController.text,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _lastNameController,
                  style: TextStyle(color: currentTheme?.textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter your last name',
                    prefixIcon: Icon(Icons.person,
                        size: 20, color: currentTheme?.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintStyle: TextStyle(
                        color: currentTheme?.textColor.withOpacity(0.5)),
                  ),
                  onChanged: (value) {
                    provider.setProfileInfo(
                      firstName: _firstNameController.text,
                      lastName: value,
                      bio: _bioController.text,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Bio Field
                Text(
                  'Bio',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: currentTheme?.textColor,
                      ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: TextStyle(color: currentTheme?.textColor),
                  decoration: InputDecoration(
                    hintText: 'Tell us a bit about yourself...',
                    prefixIcon: Icon(Icons.edit,
                        size: 20, color: currentTheme?.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintStyle: TextStyle(
                        color: currentTheme?.textColor.withOpacity(0.5)),
                  ),
                  onChanged: (value) {
                    provider.setProfileInfo(
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      bio: value,
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Continue button removed - navigation handled by main onboarding page
              ],
            ),
          ),
        );
      },
    );
  }
}
