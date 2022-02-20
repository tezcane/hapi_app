// TODO i18n
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:hapi/onboard/onboarding_controller.dart';

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
              title: '',
              body:
                  '\n\n\n\nSwipe left or hit "NEXT" to learn about hapi', // TODO arabic swipe right?
              doAnimateImage: true),
          PageModel(
              color: const Color(0xFF111328),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Earn Rewards and Improve Yourself',
              body:
                  '\n\nEarn rewards in hapi by developing religious and healthy habbits.'
                  '\n\n'
                  'Rewards are used in game but more importantly, you will collect mountains of good deeds for the Hereafter!',
              doAnimateImage: false),
          PageModel(
              color: const Color(0xFF1D1E33),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Discover Endless Islamic Wisdom',
              body:
                  '\n\nLearn deep religious and historical knowledge in an organized, beautiful and fun way.',
              doAnimateImage: false),
          PageModel(
              color: const Color(0xFF1D1E44),
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Use Helpful Resources',
              body:
                  '\n\nQuran, Hadith, Athan, Qiblah, TODO list and much more...',
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
