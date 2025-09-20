import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/user_service.dart';
import '../profile_page.dart';

class ChangeImagePage extends StatefulWidget {
  const ChangeImagePage({super.key});

  @override
  State<ChangeImagePage> createState() => _ChangeImagePageState();
}

class _ChangeImagePageState extends State<ChangeImagePage> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  String? _currentAvatarUrl;
  Uint8List? _currentAvatarBytes;

  @override
  void initState() {
    super.initState();
    _loadCurrentAvatar();
  }

  Future<void> _loadCurrentAvatar() async {
    try {
      final profile = await UserService.getCurrentUserProfile();
      if (profile?.hasAvatar == true) {
        setState(() {
          _currentAvatarUrl = profile!.avatarUrl;
        });

        // Nếu là local avatar, load base64 data
        if (UserService.isLocalAvatar(_currentAvatarUrl!)) {
          final user = UserService.currentUser;
          if (user != null) {
            final base64String = await UserService.getLocalAvatarBase64(user.id);
            if (base64String != null) {
              setState(() {
                _currentAvatarBytes = base64Decode(base64String);
              });
            }
          }
        }
      }
    } catch (e) {
      print('Failed to load current avatar: $e');
    }
  }

  Future<void> _importFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessNotification() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF8875FF),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Avatar updated successfully!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the notification sau 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      // Get current user profile to check for existing avatar
      final currentProfile = await UserService.getCurrentUserProfile();
      final oldAvatarUrl = currentProfile?.avatarUrl;

      // Ensure avatar bucket exists
      await UserService.ensureAvatarBucketExists();

      // Upload new avatar
      final newAvatarUrl = await UserService.uploadAvatar(_selectedImage!);

      // Delete old avatar if it exists
      if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
        await UserService.deleteOldAvatar(oldAvatarUrl);
      }

      if (mounted) {
        _showSuccessNotification();
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Change account Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Current/Selected Image Preview
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8687E7),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
                    : _currentAvatarBytes != null
                    ? Image.memory(
                  _currentAvatarBytes!,
                  fit: BoxFit.cover,
                )
                    : _currentAvatarUrl != null && !UserService.isLocalAvatar(_currentAvatarUrl!)
                    ? Image.network(
                  _currentAvatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
                    : _buildDefaultAvatar(),
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedImage != null)
              Text(
                'New image selected',
                style: TextStyle(
                  color: const Color(0xFF4CAF50),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 40),

            // Import from Gallery Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _importFromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF363636),
                  disabledBackgroundColor: const Color(0xFF363636).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: const Color(0xFF979797).withOpacity(0.3),
                    ),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF8687E7),
                ),
                label: const Text(
                  'Import from gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Remove Selected Image Button (only show if image is selected)
            if (_selectedImage != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isUploading ? null : _removeSelectedImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFFF4949),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF4949),
                  ),
                  label: const Text(
                    'Remove selected image',
                    style: TextStyle(
                      color: Color(0xFFFF4949),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            // Upload Button (only show if image is selected)
            if (_selectedImage != null)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8687E7),
                    disabledBackgroundColor: const Color(0xFF8687E7).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Update Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isUploading ? null : () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF8687E7),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF8687E7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Information Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF363636),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF8687E7).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8687E7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your profile image will be resized automatically for optimal display. Supported formats: JPG, PNG.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8687E7),
            Color(0xFF4CAF50),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 60,
      ),
    );
  }
}