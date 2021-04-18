import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/ui/auth/sign_up_ui.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();
  final onboarded = false.obs;
  final store = GetStorage();

  // Gets current onboarded stored
  RxBool get isOnboarded {
    onboarded.value = store.read('onboarded') ?? false;
    return onboarded;
  }

  // Write o
  Future<void> setOnboardingComplete() async {
    onboarded.value = true;
    await store.write('onboarded', true);
    Get.offAll(() => SignUpUI());
    update(); // TODO not needed
  }
}
