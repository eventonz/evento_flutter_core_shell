import 'package:evento_core/core/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/app_one_signal/app_one_signal_service_impl.dart';
import 'package:get/get.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppOneSignal>(AppOneSignalImpl());
  }
}
