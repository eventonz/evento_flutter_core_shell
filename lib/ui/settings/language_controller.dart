import 'dart:ui';
import 'package:get/get.dart';

class LanguageController extends GetxController {
  Rx<Locale>? locale;

  List languages = [
    {
      'name' : 'English',
      'code' : 'en',
      'flag' : 'us.png',
    },
    {
      'name' : 'Spanish',
      'code' : 'es',
      'flag' : 'us.png',
    }
  ];

  @override
  void onInit() {
    super.onInit();
    locale = Locale('en').obs;
  }

  setLocale(String locale) {
    this.locale!.value = Locale(locale);
    Get.updateLocale(this.locale!.value);
    update();
  }
}