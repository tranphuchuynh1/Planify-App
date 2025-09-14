import 'package:flutter/material.dart';
import 'package:hoctapflutter/ui/onboarding/onboarding_page_view.dart';
import 'package:hoctapflutter/ui/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Delay 2 giây để hiển thị splash
    await Future.delayed(const Duration(seconds: 2));

    // Kiểm tra SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final bool isOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    if (isOnboardingCompleted) {
      // Đã xem onboarding -> đi đến Welcome
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } else {
      // Chưa xem onboarding -> đi đến Onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: _buildBodyPage(),
      ),
    );
  }

  Widget _buildBodyPage() {
    return Center(
        child: Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconSplash(),
                  _buildTextSplash()
                ]
            )
        )
    );
  }

  Widget _buildIconSplash() {
    return Container(
      width: 100,
      height: 100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // bo góc cho ảnh
        child: Image.asset(
          "assets/logos/icon_android.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTextSplash() {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        child: const Text(
          "Planify",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
    );
  }
}