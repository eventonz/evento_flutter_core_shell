import 'package:evento_core/core/utils/app_global.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final imagelink = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadImageLink();
  }

  void loadImageLink() {
    imagelink.value = AppGlobals.appConfig?.home?.image ?? '';
  }
}
