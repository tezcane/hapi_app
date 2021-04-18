// TODO i18n
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:hapi/controllers/onboarding_controller.dart';

class OnboardingUI extends StatelessWidget {
  final OnboardingController onboardingController = OnboardingController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: [
          PageModel(
              color: const Color(0xFF0A0E21),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'What is hapi?',
              body: '\n\nSwipe left or hit "NEXT" to continue',
              doAnimateImage: true),
          PageModel(
              color: const Color(0xFF111328),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Islamic Lifestyle Game',
              body:
                  '\n\nGet rewarded for daily religious and healthy actions to improve your life, in this world and the next.',
              doAnimateImage: false),
          PageModel(
              color: const Color(0xFF1D1E33),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Discover Islam',
              body:
                  '\n\nLearn deep religious and historical knowledge in a beautiful and fun way.',
              doAnimateImage: false),
          PageModel(
              color: const Color(0xFF1D1E44),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Use Islamic Resources',
              body: '\n\nAthan, Qiblah, Quran, Hadith and much more...',
              doAnimateImage: false),
        ],
        skipText: '',
        finishText: 'START',
        showBullets: true,
        finishCallback: () => onboardingController.setOnboardingComplete(),
      ),
    );
  }
}
