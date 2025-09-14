import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: SingleChildScrollView(  // Thêm SingleChildScrollView để tránh overflow
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
                child: Image.asset(
                  'assets/images/profile.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // User Name
            const Text(
              'Martha Hays',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24), // Giảm từ 32 xuống 24

            // Task Statistics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '10 Task left',
                          style: TextStyle(
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
                    child: const Column(
                      children: [
                        Text(
                          '5 Task done',
                          style: TextStyle(
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

            const SizedBox(height: 32), // Giảm từ 50 xuống 32

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
                // Navigate to app settings
              },
            ),

            const SizedBox(height: 24), // Giảm từ 30 xuống 24

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

            // Change account name
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Change account name',
              onTap: () {
                // Navigate to change account name
              },
            ),

            // Change account password
            _buildMenuItem(
              icon: Icons.key_outlined,
              title: 'Change account password',
              onTap: () {
                // Navigate to change password
              },
            ),

            // Change account image
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: 'Change account Image',
              onTap: () {
                // Navigate to change profile image
              },
            ),

            const SizedBox(height: 24), // Giảm từ 30 xuống 24

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
              icon: Icons.menu,
              title: 'About US',
              onTap: () {
                // Navigate to about us
              },
            ),

            // FAQ
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'FAQ',
              onTap: () {
                // Navigate to FAQ
              },
            ),

            // Help & Feedback
            _buildMenuItem(
              icon: Icons.flash_on_outlined,
              title: 'Help & Feedback',
              onTap: () {
                // Navigate to help & feedback
              },
            ),

            // Support US
            _buildMenuItem(
              icon: Icons.thumb_up_outlined,
              title: 'Support US',
              onTap: () {
                // Navigate to support us
              },
            ),

            const SizedBox(height: 16), // Giảm từ 20 xuống 16

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

            const SizedBox(height: 24), // Thêm padding bottom để tránh bị che bởi bottom navigation
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 4), // Giảm từ 8 xuống 4
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
        dense: true, // Thêm dense để giảm height của ListTile
      ),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Handle logout logic here
                      print('User logged out');
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
                SizedBox(height: 30,)
              ],
            ),
          ],
        );
      },
    );
  }
}