import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/onboard/auth/sign_up_ui.dart';

class OnboardingC extends GetxHapi {
  static OnboardingC get to => Get.find();

  bool onboarded = false;

  bool get isOnboarded {
    onboarded = s.rd('onboarded') ?? false;
    return onboarded;
  }

  Future<void> setOnboardingComplete() async {
    onboarded = true;
    await s.wr('onboarded', true);
    Get.offAll(() => SignUpUI());
    //update(); // not needed
  }
}
