import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/challenge_info.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'challenge_controller.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChallengeController());
    return Scaffold(
        appBar: AppBar(
          title: AppText(
            controller.item.title!,
            style: AppStyles.appBarTitle,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.dataSnapshot.value == DataSnapShot.loaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: controller.challengeInfo.media!.image!.url!,
                        placeholder: (_, val) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (_, val, val2) => const Center(
                            child: NoDataFoundLayout(
                          errorMessage: 'No Image Found',
                        )),
                        width: double.infinity,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                controller.challengeInfo.title!,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: DynamicButton(
                                  topPosition: true,
                                  buttons: controller.challengeInfo.buttons!,
                                ),
                              ),
                              AppText(
                                controller.challengeInfo.content!,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DynamicButton(
                            topPosition: false,
                            buttons: controller.challengeInfo.buttons!,
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (controller.dataSnapshot.value ==
                    DataSnapShot.error) {
                  return Center(
                      child:
                          RetryLayout(onTap: controller.getChallengeDetails));
                } else {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
              }),
            )
          ],
        ));
  }
}

class DynamicButton extends StatelessWidget {
  const DynamicButton(
      {Key? key, required this.buttons, required this.topPosition})
      : super(key: key);
  final List<Buttons> buttons;
  final bool topPosition;

  @override
  Widget build(BuildContext context) {
    final ChallengeController controller = Get.find();
    late Buttons button;
    if (topPosition) {
      button = buttons.firstWhere((x) => x.location == 'top');
    } else {
      button = buttons.firstWhere((x) => x.location != 'top');
    }
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        color: AppHelper.hexToColor(button.color!),
        onPressed: () => controller.decide(button),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              button.label!.text!,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
