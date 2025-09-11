import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/db/models/athlete_extra_details.dart';
import 'package:evento_core/core/overlays/blur_loading.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_theme.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/athlete_race_no.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/split_data_table.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes/athlete_details/athlete_details_controller.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:country_flags/country_flags.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:evento_core/ui/common_components/split_data_table_2.dart';

class AthleteDetailsScreen extends StatelessWidget {
  const AthleteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthleteDetailsController());
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return GetBuilder(
        init: controller,
        builder: (controller) {
          print('VERSION2: ${controller.version2}');
          return Scaffold(
            backgroundColor: isLightMode
                ? AppColors.greyLighter
                : AppThemeColors.darkBackground,
            appBar: AppBar(
              backgroundColor: isLightMode
                  ? AppColors.greyLighter
                  : AppThemeColors.darkBackground,
              surfaceTintColor:
                  isLightMode ? Colors.transparent : Colors.transparent,
              shadowColor: isLightMode
                  ? Colors.black.withOpacity(0.1)
                  : Colors.transparent,
              actions: [
                if (controller.selEntrantA != null ||
                    controller.selEntrant != null)
                  StreamBuilder<AppAthleteDb>(
                      stream: controller.getSingleAthlete(
                          controller.selEntrant != null
                              ? controller.selEntrant!.athleteId
                              : controller.selEntrantA!.id),
                      builder: (_, snap) {
                        if (snap.hasData && controller.canFollow) {
                          final isFollowed = snap.data!.isFollowed;
                          if (isFollowed) {
                            return IconButton(
                              onPressed: () {
                                controller.updateAthlete(
                                    snap.data!, isFollowed);
                                if (Get.arguments['on_follow'] != null) {
                                  print('kk');
                                  Get.arguments['on_follow']!();
                                }
                              },
                              icon: Icon(
                                Icons.star,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.accentDark
                                    : AppColors.accentLight,
                              ),
                            );
                          }
                          return const SizedBox();
                        } else {
                          return const SizedBox();
                        }
                      }),
                IconButton(
                    onPressed: controller.getSplitDetails,
                    icon: const Icon(Icons.refresh)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Row(
                    children: [
                      if ((controller.selEntrant?.country ??
                              controller.selEntrantA?.country ??
                              '')
                          .isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CountryFlag.fromCountryCode(
                            (controller.selEntrant?.country ??
                                    controller.selEntrantA?.country ??
                                    '')
                                .toLowerCase(),
                            height: 20,
                            width: 30,
                          ),
                        ),
                      if ((controller.selEntrant?.country ??
                              controller.selEntrantA?.country ??
                              '')
                          .isNotEmpty)
                        const SizedBox(width: 8),
                      AthleteRaceNo(
                        number: controller.selEntrant?.disRaceNo ??
                            controller.selEntrantA?.disRaceNo ??
                            '',
                        width: 20.w,
                      ),
                    ],
                  ),
                )
              ],
            ),
            body: controller.loading.value
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : NestedScrollView(
                    physics: controller.athleteSplitDataSnap.value !=
                            DataSnapShot.loaded
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          backgroundColor: isLightMode
                              ? AppColors.greyLighter
                              : AppThemeColors.darkBackground,
                          surfaceTintColor: isLightMode
                              ? Colors.transparent
                              : Colors.transparent,
                          automaticallyImplyLeading: false,
                          centerTitle: false,
                          pinned: false,
                          toolbarHeight: 0,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Container(
                              decoration:
                                  AppThemeStyles.cardDecoration(context),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Athlete Name Section
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 8),
                                    child: AppText(
                                      controller.selEntrant?.name ??
                                          controller.selEntrantA?.name ??
                                          '',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      maxLines: 2,
                                      color: isLightMode
                                          ? AppColors.black
                                          : AppColors.white,
                                    ),
                                  ),

                                  // Profile Image and Info Section
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Wrap(
                                      children: [
                                        if ((controller
                                                    .selEntrant?.profileImage ??
                                                controller.selEntrantA
                                                    ?.profileImage ??
                                                '')
                                            .isNotEmpty) ...[
                                          Obx(() => GestureDetector(
                                                onTap: controller
                                                    .toggleEnlargedImage,
                                                child: AnimatedContainer(
                                                  curve: Curves.easeInOutExpo,
                                                  duration: const Duration(
                                                      milliseconds: 350),
                                                  width: controller
                                                          .showEnglargedImage
                                                          .value
                                                      ? 100.w
                                                      : 20.w,
                                                  height: controller
                                                          .showEnglargedImage
                                                          .value
                                                      ? 40.h
                                                      : 8.h,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    child: CachedNetworkImage(
                                                      imageUrl: controller
                                                              .selEntrant
                                                              ?.profileImage ??
                                                          controller.selEntrantA
                                                              ?.profileImage ??
                                                          '',
                                                      placeholder: (_, val) =>
                                                          const Center(
                                                              child: CircularProgressIndicator
                                                                  .adaptive()),
                                                      errorWidget: (_, val,
                                                              val2) =>
                                                          const Center(
                                                              child: Center(
                                                                  child: Icon(
                                                                      FeatherIcons
                                                                          .alertTriangle))),
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          Obx(() => SizedBox(
                                                width: controller
                                                        .showEnglargedImage
                                                        .value
                                                    ? 0
                                                    : 4.w,
                                              )),
                                        ],
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: AppText(
                                            (controller.selEntrant?.info ??
                                                    controller
                                                        .selEntrantA?.info ??
                                                    '')
                                                .replaceAll('null', '')
                                                .trim(),
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 6,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Additional Athlete Details Section
                                  StreamBuilder<List<AppAthleteExtraDetailsDb>>(
                                      stream:
                                          controller.getSingleAthleteDetails(
                                              controller.selEntrant != null
                                                  ? controller
                                                      .selEntrant!.athleteId
                                                  : controller.selEntrantA!.id),
                                      builder: (_, snap) {
                                        print(snap.connectionState);
                                        print(snap.error);
                                        if (snap.hasData || snap.hasError) {
                                          var data = snap.data;
                                          if ((data ?? []).isEmpty) {
                                            data = null;
                                          }

                                          print(
                                              'controller.selEntrantA?.athleteDetails ${controller.selEntrant != null ? controller.selEntrant!.athleteId : controller.selEntrantA!.id} ${controller.selEntrantA?.athleteDetails}');
                                          final details = data ??
                                              (controller.selEntrantA
                                                          ?.athleteDetails ??
                                                      [])
                                                  .map((details) {
                                                return AppAthleteExtraDetailsDb(
                                                    id: 0,
                                                    athleteId:
                                                        details.athleteNumber,
                                                    name: details.name,
                                                    eventId:
                                                        AppGlobals.selEventId,
                                                    country: details.country,
                                                    athleteNumber:
                                                        details.athleteNumber);
                                              }).toList();
                                          if (details.isEmpty) {
                                            return const SizedBox(height: 0);
                                          }
                                          return Column(
                                            children: [
                                              // Divider before additional details
                                              Divider(
                                                height: 1,
                                                thickness: 0.5,
                                                color: isLightMode
                                                    ? AppColors.darkgrey
                                                        .withOpacity(0.2)
                                                    : AppColors.greyLight
                                                        .withOpacity(0.2),
                                                indent: 16,
                                                endIndent: 16,
                                              ),
                                              ListView.separated(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: details.length,
                                                  separatorBuilder: (_, i) {
                                                    return Divider(
                                                        height: 1,
                                                        thickness: 0.5,
                                                        color: isLightMode
                                                            ? AppColors.darkgrey
                                                                .withOpacity(
                                                                    0.2)
                                                            : AppColors
                                                                .greyLight
                                                                .withOpacity(
                                                                    0.2),
                                                        indent: 16,
                                                        endIndent: 16);
                                                  },
                                                  itemBuilder: (_, i) {
                                                    return AthleteDetailsTile(
                                                        athleteExtraDetails:
                                                            details[i]);
                                                  }),
                                            ],
                                          );
                                        } else {
                                          return const SizedBox(height: 0);
                                        }
                                      }),

                                  // Follow Button Section
                                  StreamBuilder<AppAthleteDb>(
                                      stream: controller.getSingleAthlete(
                                          controller.selEntrant != null
                                              ? controller.selEntrant!.athleteId
                                              : controller.selEntrantA!.id),
                                      builder: (_, snap) {
                                        final isFollowed =
                                            snap.data?.isFollowed ?? false;
                                        return Column(
                                          children: [
                                            // Divider before follow button
                                            Divider(
                                                height: 1,
                                                thickness: 0.5,
                                                color: isLightMode
                                                    ? AppColors.darkgrey
                                                        .withOpacity(0.2)
                                                    : AppColors.greyLight
                                                        .withOpacity(0.2),
                                                indent: 16,
                                                endIndent: 16),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: AnimatedContainer(
                                                width: double.infinity,
                                                curve: Curves.easeInOut,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                decoration: BoxDecoration(
                                                    color: isFollowed
                                                        ? AppColors.transparent
                                                        : isLightMode
                                                            ? AppColors
                                                                .accentDark
                                                            : AppColors
                                                                .accentLight,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: isLightMode
                                                            ? AppColors
                                                                .accentDark
                                                            : AppColors
                                                                .accentLight,
                                                        width: 0.4)),
                                                child: CupertinoButton(
                                                    padding:
                                                        const EdgeInsets.all(0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          isFollowed
                                                              ? Icons.star
                                                              : Icons
                                                                  .star_outline,
                                                          color: isFollowed
                                                              ? isLightMode
                                                                  ? AppColors
                                                                      .accentDark
                                                                  : AppColors
                                                                      .accentLight
                                                              : AppColors.white,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        AppText(
                                                          isFollowed
                                                              ? AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .following
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .follow,
                                                          fontSize: 14,
                                                          color: isFollowed
                                                              ? isLightMode
                                                                  ? AppColors
                                                                      .accentDark
                                                                  : AppColors
                                                                      .accentLight
                                                              : AppColors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      if (controller
                                                              .selEntrant !=
                                                          null) {
                                                        controller.updateAthlete(
                                                            controller
                                                                .selEntrant!,
                                                            isFollowed);
                                                        if (Get.arguments[
                                                                'on_follow'] !=
                                                            null) {
                                                          Get.arguments[
                                                                  'on_follow']!(
                                                              controller
                                                                  .selEntrant!);
                                                        }
                                                      } else if (controller
                                                              .selEntrantA !=
                                                          null) {
                                                        // If Entrants object is used
                                                        // You may need to implement updateAthlete for Entrants if not present
                                                        // For now, just call the callback
                                                        if (Get.arguments[
                                                                'on_follow'] !=
                                                            null) {
                                                          Get.arguments[
                                                                  'on_follow']!(
                                                              controller
                                                                  .selEntrantA!);
                                                        }
                                                      }
                                                    }),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!controller.version2)
                          SliverAppBar(
                            backgroundColor: isLightMode
                                ? AppColors.greyLighter
                                : AppThemeColors.darkBackground,
                            surfaceTintColor: isLightMode
                                ? Colors.transparent
                                : Colors.transparent,
                            automaticallyImplyLeading: false,
                            pinned: true,
                            titleSpacing: 0,
                            toolbarHeight: 49,
                            title: Obx(() {
                              if (controller.athleteSplitDataSnap.value ==
                                  DataSnapShot.loaded) {
                                return Column(
                                  children: [
                                    TabBar(
                                      controller: controller.tabController,
                                      enableFeedback: true,
                                      labelColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppColors.accentDark
                                              : AppColors.accentLight,
                                      unselectedLabelColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppColors.accentDark
                                                  .withOpacity(0.8)
                                              : AppColors.accentLight
                                                  .withOpacity(0.8),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicatorColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppColors.accentDark
                                                  .withOpacity(0.8)
                                              : AppColors.accentLight
                                                  .withOpacity(0.8),
                                      tabs: controller.detailsTabs,
                                    ),
                                    Divider(
                                        height: 1,
                                        thickness: .5,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.darkgrey
                                            : AppColors.greyLight),
                                  ],
                                );
                              } else {
                                return const SizedBox();
                              }
                            }),
                          ),
                      ];
                    },
                    body: Obx(() {
                      if (controller.athleteSplitDataSnap.value ==
                          DataSnapShot.loaded) {
                        if (controller.version2) {
                          return ListView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            children: [
                              // Summary Card (if present)
                              if (controller.items
                                  .any((item) => item.type == 'summary'))
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration:
                                      AppThemeStyles.cardDecoration(context),
                                  child: SummaryDataContent2(
                                    summary: controller.items
                                        .firstWhere(
                                          (item) => item.type == 'summary',
                                          orElse: () => controller.items.first,
                                        )
                                        .data,
                                  ),
                                ),

                              // Individual Cards for each splits type
                              ...controller.items
                                  .where((item) => item.type != 'summary')
                                  .map((item) {
                                if (item.type == 'title') {
                                  // Title should not be in a card
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildSplitsContent(
                                        context, item, controller),
                                  );
                                } else {
                                  // Other content goes in cards
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration:
                                        AppThemeStyles.cardDecoration(context),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _buildSplitsContent(
                                          context, item, controller),
                                    ),
                                  );
                                }
                              }).toList(),
                            ],
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Container(
                            decoration: AppThemeStyles.cardDecoration(context),
                            child: TabBarView(
                              controller: controller.tabController,
                              children: _buildTabViews(controller),
                            ),
                          ),
                        );
                      } else if (controller.athleteSplitDataSnap.value ==
                          DataSnapShot.error) {
                        return Center(
                            child:
                                RetryLayout(onTap: controller.getSplitDetails));
                      } else {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      }
                    }),
                  ),
          );
        });
  }

  Widget _buildSplitsContent(
      BuildContext context, dynamic item, AthleteDetailsController controller) {
    if (item.type == 'externallinks') {
      // Return individual cards for each external link
      return Column(
        children: (item.data as List<dynamic>).asMap().entries.map((entry) {
          final index = entry.key;
          final linkData = entry.value;
          final isLast = index == (item.data as List<dynamic>).length - 1;
          final isLightMode = Theme.of(context).brightness == Brightness.light;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
            decoration: BoxDecoration(
              color: isLightMode ? AppColors.white : AppColors.darkBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLightMode
                    ? AppColors.greyLight.withOpacity(0.3)
                    : AppColors.greyLight.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isLightMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: _buildSingleExternalLink(context, linkData, controller),
          );
        }).toList(),
      );
    } else if (item.type == 'title') {
      return SplitTitleContent(title: item.data);
    } else if (item.type == 'splits') {
      return SplitNewDataContent2(
          splitDataList: item.splits ?? [], showSplit: false);
    } else if (item.type == 'segmentedsplit') {
      return SegmentedSplitDataContent(
        data: item.data ?? [],
        segments: item.segments ?? [],
        columns: item.columns ?? [],
      );
    } else if (item.type == 'pace') {
      return PaceDataContent(data: item.data ?? []);
    }
    return const SizedBox();
  }

  Widget _buildSingleExternalLink(BuildContext context, dynamic linkData,
      AthleteDetailsController controller) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final disRaceNo = controller.selEntrant?.disRaceNo ??
        controller.selEntrantA?.disRaceNo ??
        '';

    return ListTile(
      onTap: () {
        launchUrl(Uri.parse(linkData.url!.replaceAll('{{RaceNo}}', disRaceNo)));
      },
      tileColor: isLightMode ? AppColors.white : AppColors.darkBlack,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: linkData.icon != null
          ? SvgPicture.asset(
              AppHelper.getSvg('${linkData.icon}'),
              height: 23,
              colorFilter: ColorFilter.mode(
                isLightMode ? AppColors.primary : AppColors.secondary,
                BlendMode.srcIn,
              ),
            )
          : null,
      title: Text(
        '${linkData.label}',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 17,
          color: isLightMode ? AppColors.black : AppColors.white,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isLightMode ? AppColors.black : AppColors.white,
      ),
    );
  }

  List<Widget> _buildTabViews(AthleteDetailsController controller) {
    print(controller.tabTitles);
    final List<Widget> views = [];
    if (controller.athleteTabDetailM == null) {
      views.add(SingleChildScrollView(
        child: SplitDataContent(
            items: controller.splitData!.itemsWrapper!, showSplit: false),
      ));
      views.add(SplitDetailsHeader(
          details: controller.splitData!.itemsWrapper!.first));
    } else {
      final tabsData = controller.athleteTabDetailM!.tabs;
      for (String tabLabel in controller.tabTitles) {
        if (tabLabel == 'summary') {
          views.add(SummaryDataContent(summary: tabsData!.summary));
        } else if (tabLabel == 'splits') {
          views.add(SplitNewDataContent(
            splitDataList: tabsData!.splits,
            showSplit: false,
          ));
        }
      }
    }
    return views;
  }
}

class AthleteDetailsTile extends StatelessWidget {
  const AthleteDetailsTile({super.key, required this.athleteExtraDetails});
  final AppAthleteExtraDetailsDb athleteExtraDetails;

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (athleteExtraDetails.country.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CountryFlag.fromCountryCode(
                athleteExtraDetails.country.toLowerCase(),
                height: 20,
                width: 30,
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (athleteExtraDetails.athleteNumber.isNotEmpty)
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                decoration: BoxDecoration(
                    color:
                        isLightMode ? AppColors.darkgrey : AppColors.darkBlack,
                    borderRadius: BorderRadius.circular(6)),
                child: AppText(
                  athleteExtraDetails.athleteNumber,
                  fontSize: 12,
                  color: isLightMode ? AppColors.white : AppColors.white,
                )),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              athleteExtraDetails.name,
              color: isLightMode ? AppColors.black : AppColors.white,
            ),
          )
        ],
      ),
    );
  }

  String getFlagEmoji(String countryCode) {
    const int offset = 127397;
    final int a = 'A'.codeUnitAt(0);
    final int z = 'Z'.codeUnitAt(0);
    const exception =
        FormatException('Provided code is not an alpha 2 country code.');
    if (countryCode.length != 2) throw exception;

    String formatted = countryCode.toUpperCase();
    final int first = formatted.codeUnitAt(0);
    final int second = formatted.codeUnitAt(1);

    if (first > z || first < a || second > z || second < a) {
      throw exception;
    }

    return String.fromCharCode(first + offset) +
        String.fromCharCode(second + offset);
  }
}
