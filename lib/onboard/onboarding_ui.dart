/* TODO delete
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:hapi/onboard/onboarding_c.dart';

class OnboardingUI extends StatelessWidget {
  final OnboardingC onboardingController = OnboardingC.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: [
          PageModel(
              color: Theme.of(context).backgroundColor,
              imageAssetPath: 'assets/images/logo/logo.png',
              title: '',
              body:
                  '\n\n\n\nSwipe left or hit "NEXT" to learn about hapi', // TODO arabic swipe right?
              doAnimateImage: true),
          PageModel(
              color: Theme.of(context).backgroundColor,
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Earn Rewards and Improve Yourself',
              body:
                  '\n\nEarn rewards in hapi by developing religious and healthy habbits.'
                  '\n\n'
                  'Rewards are used in game but more importantly, you will collect mountains of good deeds for the Hereafter!',
              doAnimateImage: false),
          PageModel(
              color: Theme.of(context).backgroundColor,
              imageAssetPath: 'assets/images/logo/logo.png',
              title: 'Discover Endless Islamic Wisdom',
              body:
                  '\n\nLearn deep religious and historical knowledge in an organized, beautiful and fun way.',
              doAnimateImage: false),
          PageModel(
              color: Theme.of(context).backgroundColor,
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
*/
