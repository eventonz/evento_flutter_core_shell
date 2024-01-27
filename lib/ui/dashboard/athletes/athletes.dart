import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/advert.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common_components/athlete_tile.dart';
import 'athletes_controller.dart';

class AthletesScreen extends StatelessWidget {
  const AthletesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthletesController());
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: AppText(
            controller.athleteText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: controller.toggleFollowed,
                icon: Obx(() => CircleAvatar(
                      backgroundColor: controller.showFollowed.value
                          ? AppColors.primary.withOpacity(0.6)
                          : AppColors.transparent,
                      maxRadius: 4.5.w,
                      child: Icon(
                        FeatherIcons.star,
                        color: controller.showFollowed.value
                            ? AppColors.white
                            : Theme.of(context).brightness == Brightness.light
                                ? AppColors.accentDark
                                : AppColors.accentLight,
                        size: 4.5.w,
                      ),
                    )))
          ],
        ),
        Obx(() => controller.dashboardController.athleteSnapData.value ==
                DataSnapShot.loading
            ? LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.5),
                minHeight: 1,
              )
            : const SizedBox(
                height: 1,
              )),
        SizedBox(
          height: 1.h,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: controller.searchTextEditController,
            onChanged: (val) => controller.searchAthletes(val),
            cursorColor: AppColors.grey,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search ${controller.athleteText}',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? AppColors.white.withOpacity(0.045)
                  : AppColors.black.withOpacity(0.045),
              prefixIcon: Icon(
                FeatherIcons.search,
                size: 4.w,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.white
                    : AppColors.black,
              ),
              suffixIcon: Obx(() => controller.searchText.value.isEmpty
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: controller.clearSearchField,
                      child: Icon(
                        FeatherIcons.x,
                        size: 4.w,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.white
                            : AppColors.black,
                      ))),
              contentPadding: const EdgeInsets.all(12),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: AppColors.black, width: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  gapPadding: 0),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: AppColors.transparent, width: 0),
                  borderRadius: BorderRadius.circular(8),
                  gapPadding: 0),
            ),
          ),
        ),
        SizedBox(
          height: 1.h,
        ),
        Container(
          width: 16.w,
          height: 1.w,
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.darkBlack
                  : AppColors.greyLighter,
              borderRadius: BorderRadius.circular(10)),
        ),
        SizedBox(
          height: 1.h,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
          if(controller.showAdvert.value)
            GestureDetector(
              onTap: () {
                controller.trackEvent('click');
                launchUrl(Uri.parse(controller.advertList.where((element) => element.type == AdvertType.banner).first.openUrl!));
              },
              child: Container(
                child: Image(image: CachedNetworkImageProvider(controller.advertList.where((element) => element.type == AdvertType.banner).first.image!), width: double.maxFinite),
              ),
            ),
          Obx(() => controller.dashboardController.athleteSnapData.value ==
                  DataSnapShot.loading
              ? Container(
            height: MediaQuery.of(context).size.height*0.5,
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.black,),
                  ),
              )
              : GetBuilder<AthletesController>(
                  builder: (_) {
                    return StreamBuilder<List<AppAthleteDb>>(
                        stream: controller
                            .watchAthletes(controller.searchText.value),
                        builder: (_, snap) {
                          if (snap.hasData) {
                            List<AppAthleteDb> entrants = snap.data!;
                            if (entrants.isEmpty) {
                              return Center(
                                  child: NoDataFoundLayout(
                                title: controller.showFollowed.value
                                    ? 'No ${controller.athleteText} being followed'
                                    : null,
                                errorMessage: controller.showFollowed.value
                                    ? 'When you follow ${controller.athleteText}, you\'ll see them here.'
                                    : 'No ${controller.athleteText} Found At Present',
                              ));
                            }
                            entrants =
                                controller.sortFilterAthletes(entrants);
                            return ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                itemCount: entrants.length + 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (_, i) {
                                  return const Divider(
                                    height: 1,
                                  );
                                },
                                itemBuilder: (_, i) {
                                  if (i == 0 || i == entrants.length + 1) {
                                    return const SizedBox.shrink();
                                  }
                                  final entrant = entrants[i - 1];
                                  return AthleteTile(
                                      entrant: entrant,
                                      onTap: () => controller
                                          .toAthleteDetails(entrant));
                                });
                          } else if (snap.hasError) {
                            return Center(
                                child:
                                    RetryLayout(onTap: controller.update));
                          } else {
                            return const Center(
                                child:
                                    CircularProgressIndicator.adaptive());
                          }
                        });
                  },
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
