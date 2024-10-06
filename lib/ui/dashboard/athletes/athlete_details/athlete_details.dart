import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/db/models/athlete_extra_details.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/athlete_race_no.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/split_data_table.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes/athlete_details/athlete_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../common_components/split_data_table_2.dart';

class AthleteDetailsScreen extends StatelessWidget {
  const AthleteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AthleteDetailsController());
    return Scaffold(
      appBar: AppBar(
         surfaceTintColor: Colors.white,
        actions: [
          StreamBuilder<AppAthleteDb>(
              stream:
                  controller.getSingleAthlete(controller.selEntrant.athleteId),
              builder: (_, snap) {
                if (snap.hasData && controller.canFollow) {
                  final isFollowed = snap.data!.isFollowed;
                  if (isFollowed) {
                    return IconButton(
                      onPressed: () =>
                          controller.updateAthlete(snap.data!, isFollowed),
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).brightness == Brightness.light
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: AthleteRaceNo(
              number: controller.selEntrant.disRaceNo ?? '',
              width: 20.w,
            ),
          )
        ],
      ),
      body: Obx(() {
        return NestedScrollView(
          physics: controller.athleteSplitDataSnap.value != DataSnapShot.loaded
              ? const NeverScrollableScrollPhysics()
              : null,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                surfaceTintColor: Colors.white,
                title: AppText(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.white
                      : AppColors.darkBlack,
                  controller.selEntrant.name,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  maxLines: 2,
                ),
                automaticallyImplyLeading: false,
                centerTitle: false,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        children: [
                          if (controller
                              .selEntrant.profileImage.isNotEmpty) ...[
                            Obx(() => GestureDetector(
                                  onTap: controller.toggleEnlargedImage,
                                  child: AnimatedContainer(
                                    curve: Curves.easeInOutExpo,
                                    duration: const Duration(milliseconds: 350),
                                    width: controller.showEnglargedImage.value
                                        ? 100.w
                                        : 20.w,
                                    height: controller.showEnglargedImage.value
                                        ? 40.h
                                        : 8.h,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            controller.selEntrant.profileImage,
                                        placeholder: (_, val) => const Center(
                                            child: CircularProgressIndicator
                                                .adaptive()),
                                        errorWidget: (_, val, val2) =>
                                            const Center(
                                                child: Center(
                                                    child: Icon(FeatherIcons
                                                        .alertTriangle))),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )),
                            Obx(() => SizedBox(
                                  width: controller.showEnglargedImage.value
                                      ? 0
                                      : 4.w,
                                )),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: AppText(
                              controller.selEntrant.info,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 6,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamBuilder<List<AppAthleteExtraDetailsDb>>(
                          stream: controller.getSingleAthleteDetails(
                              controller.selEntrant.athleteId),
                          builder: (_, snap) {
                            if (snap.hasData) {
                              final details = snap.data ?? [];
                              if (details.isEmpty) {
                                return SizedBox(height: 2.h);
                              }
                              return ListView.separated(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: details.length,
                                  separatorBuilder: (_, i) {
                                    return Divider(
                                        height: 1,
                                        thickness: .5,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.darkgrey
                                            : AppColors.greyLight);
                                  },
                                  itemBuilder: (_, i) {
                                    return AthleteDetailsTile(
                                        athleteExtraDetails: details[i]);
                                  });
                            } else if (snap.hasError) {
                              return CupertinoButton(
                                  onPressed: () {},
                                  padding: const EdgeInsets.all(8),
                                  child: const AppText(
                                    'Retry',
                                    fontSize: 14,
                                  ));
                            } else {
                              return const CircularProgressIndicator.adaptive();
                            }
                          }),
                    ),
                    StreamBuilder<AppAthleteDb>(
                        stream: controller
                            .getSingleAthlete(controller.selEntrant.athleteId),

                        builder: (_, snap) {
                          print('snap ${controller.selEntrant.athleteId} ${snap.data}');
                          if (snap.hasData && controller.canFollow) {
                            final isFollowed = snap.data!.isFollowed;
                            return Column(
                              children: [
                                AnimatedContainer(
                                  width: double.infinity,
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                      color: !snap.data!.canFollow ? Theme.of(context).disabledColor : (isFollowed
                                          ? AppColors.transparent
                                          : Theme.of(context).brightness ==
                                          Brightness.light
                                          ? AppColors.accentDark
                                          : AppColors.accentLight),
                                      borderRadius: BorderRadius.circular(6),
                                      border: !snap.data!.canFollow ? null : Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppColors.accentDark
                                              : AppColors.accentLight,
                                          width: 0.4)),
                                  child: CupertinoButton(
                                      padding: const EdgeInsets.all(0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isFollowed
                                                ? Icons.star
                                                : Icons.star_outline,
                                            color: isFollowed
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.accentDark
                                                    : AppColors.accentLight
                                                : AppColors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          AppText(
                                            isFollowed ? 'Following' : 'Follow',
                                            fontSize: 14,
                                            color: isFollowed
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? AppColors.accentDark
                                                    : AppColors.accentLight
                                                : AppColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                      onPressed: !snap.data!.canFollow ? null : () => controller.updateAthlete(
                                          snap.data!, isFollowed)),
                                ),
                                if(!snap.data!.canFollow)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 4.0),
                                  child: Text('Follow not available until Race Number has been assigned', style: TextStyle(
                                    fontSize: 10,
                                  ),),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Divider(
                                    height: 1,
                                    thickness: .5,
                                    color: Theme.of(context).brightness == Brightness.light
                                                    ?  AppColors.darkgrey :AppColors.grey
                                ),
                              ],
                            );
                          } else if (snap.hasError) {
                            return CupertinoButton(
                                onPressed: () {},
                                padding: const EdgeInsets.all(8),
                                child: const AppText(
                                  'Retry',
                                  fontSize: 14,
                                ));
                          } else {
                            return const CircularProgressIndicator.adaptive();
                          }
                        }),
                  ],
                ),
              ),
              if(!controller.version2)
              SliverAppBar(
                surfaceTintColor: Colors.white,
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
                          labelColor: Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.accentDark
                                                    : AppColors.accentLight,
                          unselectedLabelColor:
                              Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.accentDark.withOpacity(0.8)
                                                    : AppColors.accentLight.withOpacity(0.8),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.accentDark.withOpacity(0.8)
                                                    : AppColors.accentLight.withOpacity(0.8),
                          tabs: controller.detailsTabs,
                        ),
                        Divider(
                            height: 1,
                            thickness: .5,
                            color: Theme.of(context).brightness == Brightness.light
                                            ?  AppColors.darkgrey :AppColors.greyLight
                        ),
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
            if (controller.athleteSplitDataSnap.value == DataSnapShot.loaded) {

              if(controller.version2) {
                return ListView.builder(itemBuilder: (_, index) {
                  if(controller.items[index].type == 'summary') {
                    return SummaryDataContent2(
                        summary: controller.items[index].data);
                  } else if (controller.items[index].type == 'externallinks') {
                    return ExternalLinkContent(link: controller.items[index].data, disRaceNo: controller.selEntrant.disRaceNo ?? '');
                  } else if (controller.items[index].type == 'title') {
                    return SplitTitleContent(title: controller.items[index].data);
                  } else if (controller.items[index].type == 'splits') {
                    return SplitNewDataContent2(splitDataList: controller.items[index].splits ?? [], showSplit: false);
                  } else if (controller.items[index].type == 'segmentedsplit') {
                    return SegmentedSplitDataContent(
                        data: controller.items[index].data ?? [],
                        segments: controller.items[index].segments ?? [],
                        columns: controller.items[index].columns ?? [],
                    );
                  } else if (controller.items[index].type == 'pace') {
                    return PaceDataContent(data: controller.items[index].data ?? []);
                  }
                  return const SizedBox();
                }, itemCount: controller.items.length, shrinkWrap: true);
              }

              return TabBarView(
                controller: controller.tabController,
                children: _buildTabViews(controller),
              );
            } else if (controller.athleteSplitDataSnap.value ==
                DataSnapShot.error) {
              return Center(
                  child: RetryLayout(onTap: controller.getSplitDetails));
            } else {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
          }),
        );
      }),
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
    return Row(
      children: [
        if (athleteExtraDetails.country.isNotEmpty) ...[
          AppText(
            getFlagEmoji(athleteExtraDetails.country),
            fontSize: 20,
          ),
          const SizedBox(width: 12),
        ],
        if(athleteExtraDetails.athleteNumber.isNotEmpty)
        Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.darkBlack
                    : AppColors.greyLighter,
                borderRadius: BorderRadius.circular(6)),
            child: AppText(
              athleteExtraDetails.athleteNumber,
              fontSize: 12,
            )),
        const SizedBox(width: 12),
        AppText(athleteExtraDetails.name)
      ],
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
