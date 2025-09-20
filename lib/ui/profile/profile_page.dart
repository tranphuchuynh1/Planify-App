import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hoctapflutter/ui/profile/profile_management/change_image_page.dart';
import 'package:hoctapflutter/ui/profile/profile_management/change_name_page.dart';
import 'package:hoctapflutter/ui/profile/profile_management/change_password_page.dart';

import '../../core/authentications/authentication_gate.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/task_service.dart';
import '../../core/services/user_service.dart';
import '../../core/models/user_model.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, int> _taskStats = {
    'total': 0,
    'completed': 0,
    'pending': 0,
  };
  bool _isLoadingStats = true;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;
  Uint8List? _localAvatarBytes;

  @override
  void initState() {
    super.initState();
    _loadTaskStats();
    _loadUserProfile();
  }

  Future<void> _loadTaskStats() async {
    try {
      final stats = await TaskService.getTaskStats();
      setState(() {
        _taskStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load task statistics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoadingProfile = true;
        _localAvatarBytes = null; // Reset local avatar bytes
      });

      // Force reload profile from both Supabase and local
      final profile = await UserService.getCurrentUserProfile();

      setState(() {
        _userProfile = profile;
      });

      // Load local avatar if exists
      if (profile?.hasAvatar == true && UserService.isLocalAvatar(profile!.avatarUrl!)) {
        final user = UserService.currentUser;
        if (user != null) {
          final base64String = await UserService.getLocalAvatarBase64(user.id);
          if (base64String != null) {
            setState(() {
              _localAvatarBytes = base64Decode(base64String);
            });
          }
        }
      }

      setState(() {
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      print('Failed to load user profile: $e');
    }
  }

  String get _displayName {
    if (_userProfile?.hasFullName == true) {
      return _userProfile!.fullName!;
    }
    return SupabaseService.userName ?? UserService.currentUserName ?? 'User';
  }

  String get _displayEmail {
    return SupabaseService.userEmail ?? UserService.currentUserEmail ?? '';
  }

  Future<void> _navigateToChangeName() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ChangeNamePage(),
      ),
    );

    // If changes were made, reload the profile
    if (result == true) {
      await _loadUserProfile();
    }
  }

  Future<void> _navigateToChangePassword() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordPage(),
      ),
    );

    // If changes were made, show success message
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  Future<void> _navigateToChangeImage() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ChangeImagePage(),
      ),
    );

    // If changes were made, reload the profile và force rebuild
    if (result == true) {
      await _loadUserProfile();
      // Force rebuild widget để đảm bảo UI được cập nhật
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildAvatarWidget() {
    if (_userProfile?.hasAvatar != true) {
      return _buildDefaultAvatar();
    }

    final avatarUrl = _userProfile!.avatarUrl!;

    // Nếu là local avatar, hiển thị từ memory
    if (UserService.isLocalAvatar(avatarUrl)) {
      if (_localAvatarBytes != null) {
        return Image.memory(
          _localAvatarBytes!,
          fit: BoxFit.cover,
        );
      } else {
        return _buildDefaultAvatar();
      }
    }

    // Nếu là network avatar, hiển thị từ network
    return Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultAvatar();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Image
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8687E7),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _buildAvatarWidget(),
              ),
            ),

            const SizedBox(height: 20),

            // User Name - Display from UserProfile or fallback
            _isLoadingProfile
                ? const CircularProgressIndicator(
              color: Color(0xFF8687E7),
            )
                : Text(
              _displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // User Email
            Text(
              _displayEmail,
              style: const TextStyle(
                color: Color(0xFF979797),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            // Task Statistics
            _isLoadingStats
                ? const CircularProgressIndicator(color: Color(0xFF8687E7))
                : Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_taskStats['pending']} Task left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_taskStats['completed']} Task done',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Settings Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // App Settings
            _buildMenuItem(
              icon: Icons.settings,
              title: 'App Settings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App Settings coming soon!')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Account Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Change account name - Navigate to ChangeNamePage
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Change account name',
              onTap: _navigateToChangeName,
            ),

            // Change account password
            _buildMenuItem(
              icon: Icons.key_outlined,
              title: 'Change account password',
              onTap: _navigateToChangePassword,
            ),

            // Change account image
            _buildMenuItem(
              icon: Icons.image_outlined,
              title: 'Change account Image',
              onTap: _navigateToChangeImage,
            ),

            const SizedBox(height: 24),

            // Uptodo Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Uptodo',
                style: TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // About US
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'About US',
              onTap: () => _showAboutDialog(context),
            ),

            // FAQ
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'FAQ',
              onTap: () => _showFAQDialog(context),
            ),

            // Help & Feedback
            _buildMenuItem(
              icon: Icons.feedback_outlined,
              title: 'Help & Feedback',
              onTap: () => _showHelpFeedbackDialog(context),
            ),

            // Support US
            _buildMenuItem(
              icon: Icons.thumb_up_outlined,
              title: 'Support US',
              onTap: () => _showSupportDialog(context),
            ),

            const SizedBox(height: 16),

            // Log out
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Log out',
              textColor: const Color(0xFFFF4949),
              showArrow: false,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),

            const SizedBox(height: 24),
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
        size: 40,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: showArrow
            ? const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        )
            : null,
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  void _showTaskStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Task Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Total Tasks', _taskStats['total']!, const Color(0xFF8687E7)),
              const SizedBox(height: 16),
              _buildStatRow('Completed', _taskStats['completed']!, const Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              _buildStatRow('Pending', _taskStats['pending']!, const Color(0xFFFF9680)),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF8875FF),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // About US Dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'About Planify',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planify - Task Management App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'A simple and efficient todo app built with Flutter and Supabase to help you organize your daily tasks and boost productivity.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Key Features:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• User Authentication & Profile Management\n'
                      '• Create, Edit & Delete Tasks\n'
                      '• Real-time Data Synchronization\n'
                      '• Task Statistics & Progress Tracking\n'
                      '• Offline Support with Local Storage\n'
                      '• Clean & Modern User Interface',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Version: 1.0.0\n'
                      'Built with: Flutter & Supabase\n'
                      'Developer: Trần Phúc Huynh',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF8875FF),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // FAQ Dialog
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q: How do I create a new task?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: Tap the "+" button on the main screen and fill in your task details.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  'Q: Can I use the app without internet?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: Yes! The app works offline and syncs your data when you reconnect to the internet.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  'Q: How do I change my profile picture?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: Go to Profile > Change account Image and select a new photo from your gallery.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  'Q: How do I delete my account?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A: Contact our support team through Help & Feedback for account deletion requests.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF8875FF),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Help & Feedback Dialog
  void _showHelpFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Help & Feedback',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help or have suggestions?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Contact Us:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Email: tranphuchuynh1@gmail.com\n'
                    'Telegram: @devflutter2004\n'
                    'Phone: +84 946 915 062',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'We typically respond within 24 hours and appreciate your feedback to improve UpTodo!',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF8687E7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening email app...'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                      // TODO: Implement mailto functionality
                    },
                    child: const Text(
                      'Send Email',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Support US Dialog
  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Support UpTodo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Love using UpTodo?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Help us keep improving by:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Rate us 5 stars on app stores\n'
                    'Share UpTodo with friends\n'
                    'Send us your feedback\n'
                    'Buy us a coffee (coming soon)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Your support means the world to us!',
                style: TextStyle(
                  color: Color(0xFF8687E7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Later',
                      style: TextStyle(
                        color: Color(0xFF8687E7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you for your support!'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );
                      // TODO: Implement rating/sharing functionality
                    },
                    child: const Text(
                      'Rate App',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF363636),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log out',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF8687E7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      try {
                        await SupabaseService.signOut();

                        // Chuyển về AuthGate, nó sẽ tự động hiển thị LoginPage
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const AuthenticationGate()),
                                (route) => false,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logout failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        color: Color(0xFFFF4949),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}