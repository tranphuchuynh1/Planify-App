// class con : role is screen interface

import 'package:flutter/material.dart';
import 'package:hoctapflutter/untils/enums/onboarding_page_position.dart';

class OnboardingChildPage extends StatelessWidget {
  final OnboardingPagePosition onboardingPagePosition;
  final VoidCallback nextOnPressed;
  final VoidCallback backOnPressed;
  final VoidCallback skipOnPressed;

  const OnboardingChildPage({
    super.key,
    required this.onboardingPagePosition,
    required this.nextOnPressed,
    required this.backOnPressed,
    required this.skipOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Column(
            children: [
              // Phần content có thể scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSkipButton(),
                      _buildOnboardingImage(),
                      _buildOnboardingControl(),
                      _buildOnboardingTitleAndContent(),
                      const SizedBox(height: 50), // Khoảng cách buffer
                    ],
                  ),
                ),
              ),
              // Buttons luôn cố định ở dưới cùng
              _buildOnboardingNextAndPrevButton(),
            ],
          ),
        )
    );
  }

  Widget _buildSkipButton() {
    return Container(
      width: double.infinity, // Đảm bảo full width
      margin: const EdgeInsets.only(top: 26),
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: 24), // Thêm padding
      child: TextButton(
        onPressed: (){
          skipOnPressed();
        }, child: Text("SKIP",
          style: TextStyle(
            fontSize: 16,
            fontFamily: "Lato",
            color: Colors.white.withValues(alpha: 0.7),
          )
      ),
      ),
    );
  }

  Widget _buildOnboardingImage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: Image.asset(onboardingPagePosition.onboardingPageImage(),
        height: 296,
        width: 271,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildOnboardingControl() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 4,
            width: 26,
            decoration: BoxDecoration(
              color: onboardingPagePosition == OnboardingPagePosition.page1 ? Colors.white : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(56),
            ),
          ),
          Container(
            height: 4,
            width: 26,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: onboardingPagePosition == OnboardingPagePosition.page2 ? Colors.white : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(56),
            ),
          ),
          Container(
            height: 4,
            width: 26,
            decoration: BoxDecoration(
              color: onboardingPagePosition == OnboardingPagePosition.page3 ? Colors.white : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(56),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOnboardingTitleAndContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(onboardingPagePosition.onboardingPageTitle(), style: TextStyle(
              color: Colors.white.withValues(alpha: 0.87), // Tăng opacity một chút
              fontFamily: "Lato",
              fontSize: 32,
              fontWeight: FontWeight.bold
          ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 42),
          Text(onboardingPagePosition.onboardingPageContent(), style: TextStyle(
            color: Colors.white.withValues(alpha: 0.67), // Giảm opacity cho subtitle
            fontFamily: "Lato",
            fontSize: 16,
          ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildOnboardingNextAndPrevButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Tăng padding bottom
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              backOnPressed();
            },
            child: Text(
                "BACK",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Lato",
                  color: Colors.white.withValues(alpha: 0.44), // Giảm opacity cho BACK
                )
            ),
          ),
          const Spacer(),
          ElevatedButton(
              onPressed: () {
                nextOnPressed.call();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8875FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)
                  )
              ),
              child: Text(
                onboardingPagePosition == OnboardingPagePosition.page3 ? "GET STARTED" : "NEXT",
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Lato",
                    color: Colors.white,
                    fontWeight: FontWeight.w400
                ),
              )
          )
        ],
      ),
    );
  }
}