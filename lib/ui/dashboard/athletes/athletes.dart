import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/advert.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_theme.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/preferences.dart';
import '../../common_components/athlete_tile.dart';
import 'athletes_controller.dart';

class AthletesScreen extends StatelessWidget {
  const AthletesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthletesController());

    Future.delayed(const Duration(seconds: 1), () {
      if (!Preferences.getBool('is_tooltip', false)) {
        controller.tooltipController.showTooltip();
        Preferences.setBool('is_tooltip', true);
      }
    });

    controller.checkAdvert(false);
    return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.greyLighter
            : AppColors.darkBlack,
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.darkBlack,
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.darkBlack,
          shadowColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.transparent,
          automaticallyImplyLeading: false,
          title: AppText(
            controller.athleteText,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: false,
          actions: [
            if (false)
              IconButton(
                  padding: const EdgeInsets.all(0),
                  //onPressed: controller.toggleFollowed,
                  onPressed: () {},
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
        body: Column(
          children: [
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
            Expanded(
              child: SingleChildScrollView(
                controller: controller.scrollController,
                child: Column(
                  children: [
                    // Search Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: AppThemeStyles.cardDecoration(context),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Search here for ${controller.athleteText.toLowerCase()}',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 12),
                            SuperTooltip(
                              showBarrier: false,
                              hasShadow: false,
                              arrowBaseWidth: 0,
                              arrowLength: 0,
                              arrowTipDistance: 0,
                              arrowTipRadius: 0,
                              verticalOffset: 20,
                              backgroundColor: Colors.transparent,
                              borderWidth: 0,
                              borderColor: Colors.transparent,
                              minimumOutsideMargin: 0,
                              hideTooltipOnBarrierTap: true,
                              hideTooltipOnTap: true,
                              controller: controller.tooltipController,
                              content: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: ShapeDecoration(
                                      shape: TooltipShapeBorder(
                                        radius: 5,
                                      ),
                                      color: AppColors.black),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .searchForAthletesUsingNameOrRaceNo,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  controller.getAthletes('', init: true);
                                  Get.to(const AthletesSearchScreen());
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    controller.focusNode.requestFocus();
                                  });
                                },
                                child: TextField(
                                  controller:
                                      controller.searchTextEditController,
                                  onChanged: (val) =>
                                      controller.searchAthletes(val),
                                  cursorColor: AppColors.grey,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.darkgrey
                                        : AppColors.splitLightGrey,
                                  ),
                                  decoration: InputDecoration(
                                      enabled: false,
                                      isDense: true,
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.greyLight
                                            : AppColors.grey,
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[100]
                                          : Colors.grey[800],
                                      prefixIcon: Icon(
                                        FeatherIcons.search,
                                        size: 5.w,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.grey
                                            : AppColors.greyLight,
                                      ),
                                      suffixIcon: Obx(() => controller
                                              .searchText.value.isEmpty
                                          ? const SizedBox()
                                          : GestureDetector(
                                              onTap:
                                                  controller.clearSearchField,
                                              child: Icon(
                                                FeatherIcons.x,
                                                size: 4.w,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.grey
                                                    : AppColors.greyLight,
                                              ))),
                                      contentPadding: const EdgeInsets.all(12),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gapPadding: 0),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gapPadding: 0),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gapPadding: 0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Banner Advert
                    if (controller.showAdvert.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: AppThemeStyles.cardDecoration(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GestureDetector(
                              onTap: () {
                                controller.trackEvent('click');
                                launchUrl(Uri.parse(controller.advertList
                                    .where((element) =>
                                        element.type == AdvertType.banner)
                                    .first
                                    .openUrl!));
                              },
                              child: Image(
                                  image: CachedNetworkImageProvider(controller
                                      .advertList
                                      .where((element) =>
                                          element.type == AdvertType.banner)
                                      .first
                                      .image!),
                                  width: double.maxFinite,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Followed Athletes Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: AppThemeStyles.cardDecoration(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: AppText(
                                'Followed ${controller.athleteText}',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            StreamBuilder<List<AppAthleteDb>>(
                              stream: controller.watchAthletes(''),
                              builder: (_, snap) {
                                if (snap.hasData) {
                                  List<AppAthleteDb> followedAthletes = snap
                                      .data!
                                      .where((athlete) => athlete.isFollowed)
                                      .toList();

                                  if (followedAthletes.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 16),
                                            AppText(
                                              'No ${controller.athleteText.toLowerCase()} being followed',
                                              fontSize: 16,
                                              color: AppColors.grey,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            AppText(
                                              'When you follow ${controller.athleteText.toLowerCase()}, you will see them here',
                                              fontSize: 14,
                                              color: AppColors.grey
                                                  .withOpacity(0.7),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: followedAthletes.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (_, i) => Divider(
                                      height: 1,
                                      thickness: 0.5,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? AppColors.darkgrey.withOpacity(0.2)
                                          : AppColors.greyLight
                                              .withOpacity(0.2),
                                    ),
                                    itemBuilder: (_, i) {
                                      final entrant = followedAthletes[i];
                                      return AthleteTile(
                                        entrant: entrant,
                                        onTap: () =>
                                            controller.toAthleteDetails(
                                          entrant,
                                          onFollow: (ent) async {
                                            print(
                                                'isFOLLOWED ${!entrant.isFollowed}');
                                            await controller.insertAthleteA(
                                                entrant, !entrant.isFollowed);
                                            if (!entrant.isFollowed) {
                                              controller
                                                  .followAthleteA(entrant);
                                            } else {
                                              controller
                                                  .unfollowAthleteA(entrant);
                                            }
                                            // controller.update();
                                          },
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: CircularProgressIndicator
                                            .adaptive()),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                  stream: controller.watchAthletes(
                                      controller.searchText.value),
                                  builder: (_, snap) {
                                    print(snap.data?.length);
                                    print(snap.hasData);
                                    if (snap.hasData) {
                                      List<AppAthleteDb> entrants = snap.data!;
                                      if (entrants.isEmpty) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 30.h),
                                          child: Center(
                                              child: NoDataFoundLayout(
                                            title: controller.showFollowed.value
                                                ? AppLocalizations.of(context)!
                                                    .noAthletesBeingFollowed(
                                                        controller.athleteText)
                                                : null,
                                            errorMessage: controller
                                                    .showFollowed.value
                                                ? AppLocalizations.of(context)!
                                                    .whenYouFollowAthleteYouWillSeeThemHere(
                                                        controller.athleteText)
                                                : AppLocalizations.of(context)!
                                                    .noAthletesFoundAtPresent(
                                                        controller.athleteText),
                                          )),
                                        );
                                      }
                                      entrants = controller
                                          .sortFilterAthletes(entrants);

                                      // Filter out followed athletes since they're shown in the dedicated card above
                                      entrants = entrants
                                          .where(
                                              (athlete) => !athlete.isFollowed)
                                          .toList();

                                      return ListView.separated(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0),
                                          itemCount: entrants.length + 2,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          separatorBuilder: (_, i) {
                                            // Don't show divider after the last item
                                            if (i == entrants.length) {
                                              return const SizedBox.shrink();
                                            }
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
                                            final entrant = entrants[i - 1];
                                            return AthleteTile(
                                                entrant: entrant,
                                                onTap: () => controller
                                                        .toAthleteDetails(
                                                            entrant,
                                                            onFollow: (ent) {
                                                      onFollow(ent) async {
                                                        print(
                                                            'isFOLLOWED ${!entrant.isFollowed}');
                                                        await controller
                                                            .insertAthleteA(
                                                                entrant,
                                                                !entrant
                                                                    .isFollowed);
                                                        if (!entrant
                                                            .isFollowed) {
                                                          controller
                                                              .followAthleteA(
                                                                  entrant);
                                                        } else {
                                                          controller
                                                              .unfollowAthleteA(
                                                                  entrant);
                                                        }
                                                        //controller.update();
                                                      }

                                                      onFollow(ent);
                                                    }));
                                          });
                                    } else if (snap.hasError) {
                                      return Center(
                                          child: RetryLayout(
                                              onTap: controller.update));
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive());
                                    }
                                  });
                            },
                          )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class TooltipShapeBorder extends ShapeBorder {
  final double arrowWidth;
  final double arrowHeight;
  final double arrowArc;
  final double radius;

  TooltipShapeBorder({
    this.radius = 0,
    this.arrowWidth = 16.0,
    this.arrowHeight = 8.0,
    this.arrowArc = 0.0,
  }) : assert(arrowArc <= 1.0 && arrowArc >= 0.0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      null ?? Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
        rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
    double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(rect.topRight.dx - 30, rect.topRight.dy)
      ..relativeLineTo(-x / 2 * r, -y * r)
      ..relativeQuadraticBezierTo(
          -x / 2 * (1 - r), -y * (1 - r), -x * (1 - r), 0)
      ..relativeLineTo(-x / 2 * r, y * r);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
