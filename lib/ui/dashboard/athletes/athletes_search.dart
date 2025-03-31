import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/advert.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_global.dart';
import '../../common_components/athlete_tile.dart';
import 'athletes_controller.dart';

class AthletesSearchScreen extends StatelessWidget {
  const AthletesSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthletesController());
    controller.checkAdvert(false);
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            surfaceTintColor: Colors.white,
            shadowColor: Colors.white,
            automaticallyImplyLeading: true,
            title: AppText(
              AppLocalizations.of(context)!.search,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true,
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: controller.focusNode,
                    controller: controller.searchTextEditController,
                    onSubmitted: (val) => controller.searchAthletes(val),
                    cursorColor: AppColors.grey,
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search ${controller.athleteText}',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.greyLight
                            : AppColors.grey,
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? AppColors.white.withOpacity(0.045)
                              : AppColors.black.withOpacity(0.045),
                      prefixIcon: Icon(
                        FeatherIcons.search,
                        size: 5.w,
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
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.white
                                    : AppColors.black,
                              ))),
                      contentPadding: const EdgeInsets.all(12),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.black, width: 0.8),
                          borderRadius: BorderRadius.circular(10),
                          gapPadding: 0),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.transparent, width: 0),
                          borderRadius: BorderRadius.circular(10),
                          gapPadding: 0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => controller
                      .searchAthletes(controller.searchTextEditController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? AppColors.white.withOpacity(0.045)
                            : AppColors.black.withOpacity(0.045),
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? AppColors.white
                            : AppColors.black,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    side: BorderSide(
                      color: AppColors.black,
                      width: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.search,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.white
                          : AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   height: 1.h,
          // ),
          // Container(
          //   width: 16.w,
          //   height: 1.w,
          //   decoration: BoxDecoration(
          //       color: Theme.of(context).brightness == Brightness.light
          //           ? AppColors.darkBlack
          //           : AppColors.greyLighter,
          //       borderRadius: BorderRadius.circular(10)),
          // ),

          SizedBox(
            height: 1.5.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.searchScrollController,
              child: Column(
                children: [
                  // This is the last updated value for athletes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Text(
                            '${AppLocalizations.of(context)!.lastUpdated}: ${controller.entrantsList.label ?? ''}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.greyLighter
                                    : AppColors.darkBlack))),
                  ),
                  Obx(() => controller
                              .dashboardController.athleteSnapData.value ==
                          DataSnapShot.loading
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        )
                      : GetBuilder<AthletesController>(
                          builder: (_) {
                            return StreamBuilder<List<AppAthleteDb>>(
                                stream: controller
                                    .watchAthletes(controller.searchText.value),
                                builder: (_, snap) {
                                  if (controller
                                      .searchAccumulatedList.isNotEmpty) {
                                    List<Entrants> entrants =
                                        controller.searchAccumulatedList;
                                    entrants = controller
                                        .sortFilterAthletesSearch(entrants);

                                    return ListView.separated(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0),
                                        itemCount: entrants.length +
                                            2 +
                                            (controller.loadingMore.value
                                                ? 1
                                                : 0),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (_, i) {
                                          return Divider(
                                              height: 1,
                                              thickness: .5,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? AppColors.darkgrey
                                                  : AppColors.greyLight);
                                        },
                                        itemBuilder: (_, i) {
                                          if (i == 0 ||
                                              i == entrants.length + 1) {
                                            return const SizedBox.shrink();
                                          }
                                          if (i == entrants.length + 2) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20,
                                              ),
                                              child: Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            );
                                          }

                                          if (snap.hasData &&
                                              snap.data!.firstWhereOrNull((a) =>
                                                      a.athleteId ==
                                                      controller
                                                          .searchAccumulatedList[
                                                              i - 1]
                                                          .id) !=
                                                  null) {
                                            controller
                                                .searchAccumulatedList[i - 1]
                                                .isFollowed = true;
                                            entrants[i - 1].isFollowed = true;
                                          } else {
                                            controller
                                                .searchAccumulatedList[i - 1]
                                                .isFollowed = false;
                                            entrants[i - 1].isFollowed = false;
                                          }

                                          final entrant = entrants[i - 1];

                                          onFollow() async {
                                            await controller.insertAthlete(
                                                entrant, !entrant.isFollowed);
                                            if (!entrant.isFollowed) {
                                              controller.followAthlete(entrant);
                                            } else {
                                              controller
                                                  .unfollowAthlete(entrant);
                                            }
                                            //controller.update();
                                          }

                                          return AthleteTile(
                                              entrant: entrant,
                                              onFollow: onFollow,
                                              onTap: () => controller
                                                  .toAthleteDetails(entrant,
                                                      onFollow: onFollow));
                                        });
                                  } else if (controller.loading.value) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 30.h),
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    );
                                  } else {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 30.h),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                                AppHelper.getImage(
                                                    'empty_search.png'),
                                                width: 65),
                                            SizedBox(height: 10),
                                            Text(AppLocalizations.of(context)!
                                                .noAthleteFound(
                                                    controller.athleteText)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                });
                          },
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
