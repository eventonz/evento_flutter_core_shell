import 'package:evento_core/core/models/event_offer.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../common_components/no_data_found_layout.dart';
import 'event_offers_controller.dart';

class EventOffersScreen extends StatelessWidget {
  const EventOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventOffersController());
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: const AppText(
          '',
          style: AppStyles.appBarTitle,
        ),
      ),
      body: Builder(builder: (context) {
        return Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.dataSnapshot.value == DataSnapShot.loaded) {
                  final eventOffers = controller.eventOffers;
                  if (eventOffers.isEmpty) {
                    return const Center(
                        child: NoDataFoundLayout(
                      errorMessage: 'No Result Found',
                    ));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: PageView(
                          onPageChanged: (val) =>
                              controller.currentPageIndex.value = val,
                          controller: controller.pageController,
                          children: [
                            for (EventOffer offer in controller.eventOffers)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 34.h,
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          offer.media!.image!.url!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: double.infinity,
                                            height: 21.h,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                  AppColors.transparent,
                                                  AppColors.transparent,
                                                  AppColors.black
                                                      .withOpacity(0.8)
                                                ])),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          offer.title!.toUpperCase(),
                                          fontSize: 14,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            for (Buttons button
                                                in offer.buttons!)
                                              if (button.type == 'label')
                                                Expanded(
                                                  child: CupertinoButton(
                                                    color: AppColors.primary,
                                                    onPressed: () =>
                                                        controller.showWebSheet(
                                                            button.label!.text!,
                                                            button
                                                                .label!.open!),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: AppText(
                                                      button.label!.text!,
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                )
                                              else if (button.type ==
                                                  'social_media')
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: CupertinoButton(
                                                    color: controller
                                                        .getSocialMediaButtonColor(
                                                            button),
                                                    onPressed: () =>
                                                        controller.showWebSheet(
                                                            null,
                                                            button.socialMedia!
                                                                .open!),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Icon(
                                                      controller
                                                          .getSocialMediaButtonIcon(
                                                              button),
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                )
                                              else
                                                const SizedBox()
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Column(
                                        children: [
                                          AppText(
                                            offer.content! + offer.content!,
                                            textAlign: TextAlign.justify,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                      ),
                      SafeArea(
                          child: Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0;
                                      i < controller.eventOffers.length;
                                      i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 2),
                                      child: GestureDetector(
                                        onTap: () => controller.changePage(i),
                                        child: Icon(
                                          Icons.fiber_manual_record,
                                          color: controller
                                                      .currentPageIndex.value ==
                                                  i
                                              ? AppColors.primary
                                              : AppColors.primary
                                                  .withOpacity(0.2),
                                          size: 3.5.w,
                                        ),
                                      ),
                                    )
                                ],
                              ))),
                    ],
                  );
                } else if (controller.dataSnapshot.value ==
                    DataSnapShot.error) {
                  return Center(
                      child: RetryLayout(onTap: controller.getEventOffers));
                } else {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }
              }),
            )
          ],
        );
      }),
    );
  }
}

class AppButtonStrip extends StatelessWidget {
  const AppButtonStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
