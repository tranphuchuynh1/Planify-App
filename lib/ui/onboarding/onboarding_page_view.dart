import 'package:flutter/material.dart';
import 'package:hoctapflutter/ui/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hoctapflutter/untils/enums/onboarding_page_position.dart';
import 'onboarding_child_page.dart';


class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();

  // Method để lưu onboarding completed và navigate
  Future<void> _completeOnboardingAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // Page 1
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page1,
            nextOnPressed: () {
              _pageController.jumpToPage(1); // jump to page 2
            },
            backOnPressed: () {
              // Page 1 không có back
            },
            skipOnPressed: () {
              _completeOnboardingAndNavigate();
            },
          ),

          // Page 2  
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page2,
            nextOnPressed: () {
              _pageController.jumpToPage(2); // jump to page 3
            },
            backOnPressed: () {
              _pageController.jumpToPage(0); // jump to page 1
            },
            skipOnPressed: () {
              _completeOnboardingAndNavigate();
            },
          ),

          // Page 3
          OnboardingChildPage(
            onboardingPagePosition: OnboardingPagePosition.page3,
            nextOnPressed: () {
              // GET STARTED button -> Complete onboarding
              _completeOnboardingAndNavigate();
            },
            backOnPressed: () {
              _pageController.jumpToPage(1); // jump to page 2
            },
            skipOnPressed: () {
              _completeOnboardingAndNavigate();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}