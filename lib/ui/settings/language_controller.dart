import 'dart:ui';
import 'package:get/get.dart';


class LanguageController extends GetxController {
  Rx<Locale> locale = Locale('en').obs; // Default to 'en'

  // Define supported languages
  final Set<String> supportedLanguages = {'en', 'fr', 'de', 'es'};


  List languages = [
    {
      'name' : 'English',
      'code' : 'en',
      'flag' : 'us.png',
    },
    {
      'name' : 'French',
      'code' : 'fr',
      'flag' : 'us.png',
    },
    {
      'name' : 'German',
      'code' : 'de',
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
     
    // Get the language code from the device
    String deviceLanguageCode = PlatformDispatcher.instance.locale.languageCode;

    // Check if the device language is supported
    if (supportedLanguages.contains(deviceLanguageCode)) {
      locale.value = Locale(deviceLanguageCode); // Use the device language
    } else {
      locale.value = const Locale('en'); // Fallback to 'en'
    }

    // Update the app's locale
    Get.updateLocale(locale.value);

    // Debugging
    print('Set Locale to: ${locale.value}');

  }

  setLocale(String locale) {
    this.locale.value = Locale(locale);
    Get.updateLocale(this.locale.value);
    update();
  }
}