import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/challenge_info.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:get/get.dart';

class ChallengeController extends GetxController {
  late Items item;
  final dataSnapshot = DataSnapShot.loading.obs;
  late ChallengeInfoM challengeInfo;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    getChallengeDetails();
  }

  void getChallengeDetails() async {
    dataSnapshot.value = DataSnapShot.loading;
    try {
      final res = await ApiHandler.genericGetHttp(url: item.actions!.url!);
      challengeInfo = ChallengeInfoM.fromJson(res.data);
      dataSnapshot.value = DataSnapShot.loaded;
    } catch (e) {
      dataSnapshot.value = DataSnapShot.error;
    }
  }

  void decide(Buttons button) async {
    final text = button.label!.text!.toLowerCase();
    if (text.contains('info')) {
      final url =
          '${button.open!}?onesignal_id=${AppGlobals.oneSignalUserId}&is_subscribed=false';
      AppHelper.showWebBottomSheet(item.title, url);
    } else if (text.contains('scan')) {
      final res = await Get.toNamed(Routes.qrScanner,
              arguments: {AppKeys.url: button.open}) ??
          {AppKeys.qrData: ''};
      if (res[AppKeys.qrData].isNotEmpty) {
        final qrCodeData = res[AppKeys.qrData];
        final str =
            '${button.open!}?qrcode=$qrCodeData&onesignal_id=${AppGlobals.oneSignalUserId}';
        AppHelper.showWebBottomSheet(item.title, str);
      }
    } else {
      ToastUtils.show(null);
    }
  }
}
