import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';

class OnboardingController extends GetxHapi {
  static OnboardingController get to => Get.find();

  final onboarded = false.obs;

  RxBool get isOnboarded {
    onboarded.value = s.rd('onboarded') ?? false;
    return onboarded;
  }

  Future<void> setOnboardingComplete() async {
    onboarded.value = true;
    await s.wr('onboarded', true);
    Get.offAll(() => SignUpUI());
    //update(); // not needed
  }
}
