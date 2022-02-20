import 'package:get/get.dart';
import 'package:hapi/main.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();
  final onboarded = false.obs;

  RxBool get isOnboarded {
    onboarded.value = s.read('onboarded') ?? false;
    return onboarded;
  }

  Future<void> setOnboardingComplete() async {
    onboarded.value = true;
    await s.write('onboarded', true);
    Get.offAll(() => SignUpUI());
    //update(); // not needed
  }
}
