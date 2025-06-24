import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/results/results_screen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:country_flags/country_flags.dart';

import '../../core/models/app_config.dart';
import '../../core/res/app_colors.dart';
import '../common_components/text.dart';
import 'leaderboard_screen_controller.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardScreenController());
    final ValueNotifier<bool> showScrollToTop = ValueNotifier(false);

    controller.scrollController.addListener(() {
      if (controller.scrollController.offset > 200) {
        if (!showScrollToTop.value) showScrollToTop.value = true;
      } else {
        if (showScrollToTop.value) showScrollToTop.value = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: AppText(
          controller.items!.title ?? '',
        ),
      ),
      body: Stack(
        children: [
          GetBuilder(
            init: controller,
            builder: (_) {
              if (controller.loading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              }
              return SingleChildScrollView(
                controller: controller.scrollController,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: .5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: DropdownButton<int>(
                          items: [
                            ...(controller.eventResponse?.data
                                    ?.where((e) =>
                                        controller.items?.listEvents
                                            ?.contains(e.eventId) ??
                                        false)
                                    .map((e) => DropdownMenuItem(
                                        value: e.eventId, child: Text(e.name)))
                                    .toList() ??
                                []),
                          ],
                          onChanged: (val) {
                            controller.changeEvent(val!);
                          },
                          icon: Icon(CupertinoIcons.chevron_down,
                              color: Colors.grey),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          value: controller.selectedEvent.value,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(5),
                          underline: Container()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 16, right: 8, top: 0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: .5,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                int tempSelectedIndex = controller.splits
                                        .indexWhere((split) =>
                                            split['id'] ==
                                            controller.selectedSplitId.value) ??
                                    0;

                                await showModalBottomSheet(
                                    context: context,
                                    elevation: 0,
                                    backgroundColor: Theme.of(context)
                                        .bottomSheetTheme
                                        .backgroundColor,
                                    builder: (_) => BottomSheet(
                                          onClosing: () {},
                                          builder: (_) {
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  ),
                                                  child: Container(
                                                    height: 320,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 16.0,
                                                                  bottom: 8.0),
                                                          child: Text(
                                                            'Split',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              CupertinoPicker(
                                                            itemExtent: 48,
                                                            scrollController:
                                                                FixedExtentScrollController(
                                                              initialItem:
                                                                  tempSelectedIndex,
                                                            ),
                                                            onSelectedItemChanged:
                                                                (val) {
                                                              tempSelectedIndex =
                                                                  val;
                                                            },
                                                            children: controller
                                                                .splits
                                                                .map(
                                                                    (split) =>
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            '${split['name']}',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 22,
                                                                            ),
                                                                          ),
                                                                        ))
                                                                .toList(),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  16.0,
                                                                  16.0,
                                                                  16.0,
                                                                  32.0),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    CupertinoButton(
                                                                  color: AppColors
                                                                      .primary,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    final selectedSplit =
                                                                        controller
                                                                            .splits[tempSelectedIndex];
                                                                    controller.setSplit(
                                                                        selectedSplit['id']
                                                                            as int);
                                                                  },
                                                                  child: Text(
                                                                    AppLocalizations.of(
                                                                            context)!
                                                                        .apply
                                                                        .toUpperCase(),
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 16),
                                                              CupertinoButton(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16),
                                                                color: Colors
                                                                    .grey[400],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                                onPressed: () {
                                                                  controller
                                                                      .setSplit(
                                                                          0); // Reset to Overall
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .clear
                                                                      .toUpperCase(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          elevation: 0,
                                        ));
                              },
                              child: Container(
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() => Text(
                                            controller.splits.firstWhereOrNull(
                                                    (split) =>
                                                        split['id'] ==
                                                        controller
                                                            .selectedSplitId
                                                            .value)?['name'] ??
                                                'Overall',
                                            style: TextStyle(fontSize: 16),
                                          )),
                                    ),
                                    Icon(CupertinoIcons.chevron_down,
                                        color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                                right: 16, left: 8, top: 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: .5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                controller.updateScrollController();
                                await showModalBottomSheet(
                                    context: context,
                                    elevation: 0,
                                    backgroundColor: Theme.of(context)
                                        .bottomSheetTheme
                                        .backgroundColor,
                                    builder: (_) => BottomSheet(
                                          onClosing: () {},
                                          builder: (_) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              child: Container(
                                                height: 360,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                CupertinoPicker(
                                                              itemExtent: 70,
                                                              scrollController:
                                                                  FixedExtentScrollController(
                                                                initialItem: (controller
                                                                            .eventResponse
                                                                            ?.data
                                                                            ?.where((element) =>
                                                                                element.eventId ==
                                                                                controller.selectedEvent.value)
                                                                            .firstOrNull
                                                                            ?.genders
                                                                            .where((element) => element.enabled)
                                                                            .toList()
                                                                            .indexWhere((element) => element.id == controller.gender) ??
                                                                        -1) +
                                                                    1,
                                                              ),
                                                              onSelectedItemChanged:
                                                                  (val) {
                                                                controller
                                                                    .setGender(
                                                                        val);
                                                              },
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    'All',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ...controller
                                                                        .eventResponse
                                                                        ?.data
                                                                        ?.where((element) =>
                                                                            element.eventId ==
                                                                            controller
                                                                                .selectedEvent.value)
                                                                        .firstOrNull
                                                                        ?.genders
                                                                        .where((element) =>
                                                                            element
                                                                                .enabled)
                                                                        .map((e) =>
                                                                            Center(
                                                                              child: Text(
                                                                                '${e.name}',
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        ?.toList() ??
                                                                    [],
                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child:
                                                                CupertinoPicker(
                                                              itemExtent: 70,
                                                              scrollController:
                                                                  controller
                                                                      .categoryScrollController,
                                                              onSelectedItemChanged:
                                                                  (val) {
                                                                controller
                                                                    .setCategory(
                                                                        val);
                                                              },
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    'All',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ...controller
                                                                        .eventResponse
                                                                        ?.data
                                                                        ?.where((element) =>
                                                                            element.eventId ==
                                                                            controller
                                                                                .selectedEvent.value)
                                                                        .firstOrNull
                                                                        ?.categories
                                                                        .map((e) =>
                                                                            Center(
                                                                              child: Text(
                                                                                '${e.name ?? e.code}',
                                                                                style: TextStyle(
                                                                                  color: Colors.black,
                                                                                ),
                                                                              ),
                                                                            ))
                                                                        ?.toList() ??
                                                                    [],
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(16.0, 16.0,
                                                          16.0, 32.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                CupertinoButton(
                                                              color: AppColors
                                                                  .primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                controller
                                                                    .filterResults();
                                                              },
                                                              child: Text(
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .apply
                                                                    .toUpperCase(),
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 16),
                                                          CupertinoButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16),
                                                            color: Colors
                                                                .grey[400],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            onPressed: () {
                                                              controller
                                                                  .setCategory(
                                                                      0);
                                                              controller
                                                                  .setGender(0);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              AppLocalizations.of(
                                                                      context)!
                                                                  .clear
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          elevation: 0,
                                        ));
                                controller.filterResults();
                              },
                              child: Container(
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.filter,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Builder(builder: (context) {
                      var category = controller.eventResponse?.data
                          ?.where((element) =>
                              element.eventId == controller.selectedEvent.value)
                          .firstOrNull
                          ?.categories
                          .where((element) => element.id == controller.category)
                          .firstOrNull;
                      var gender = controller.eventResponse?.data
                          ?.where((element) =>
                              element.eventId == controller.selectedEvent.value)
                          .firstOrNull
                          ?.genders
                          .where((element) => element.enabled)
                          .toList()
                          .where((element) => element.id == controller.gender)
                          .firstOrNull;
                      return Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                              '${AppLocalizations.of(context)!.gender} ${gender?.name ?? gender?.code ?? AppLocalizations.of(context)!.all} / ${AppLocalizations.of(context)!.category} ${category?.name ?? category?.code ?? AppLocalizations.of(context)!.all}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              )),
                          Obx(() => AnimatedOpacity(
                                opacity:
                                    controller.isRefreshed.value ? 1.0 : 0.0,
                                duration: Duration(milliseconds: 300),
                                child: Container(
                                  margin: EdgeInsets.only(left: 8),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                      ),
                      child: Row(
                        children: [
                          if (controller.search == '')
                            SizedBox(
                              width: 60,
                              child: Center(
                                  child: Text(
                                '${AppLocalizations.of(context)!.pos}.',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              )),
                            ),
                          Expanded(
                              child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '${AppLocalizations.of(context)!.name}.',
                              style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          )),
                          Container(
                            width: 80,
                            child: Center(
                                child: Text(
                              AppLocalizations.of(context)!.diff,
                              style: TextStyle(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                    if (controller.loadingResults.value)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 100),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                          itemBuilder: (_, index) {
                            if (index == controller.eventResult!.data!.length) {
                              return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ));
                            }

                            var athlete = controller.eventResult!.data[index];

                            var timeDiff = controller.gender == -1 &&
                                    controller.category == -1
                                ? athlete.timeBehindOverallLeader
                                : (controller.category == -1
                                    ? athlete.timeBehindGenderLeader
                                    : athlete.timeBehindCategoryLeader);

                            return GestureDetector(
                              onTap: () {
                                // if (!(controller.items?.linkToDetail ?? false)) {
                                //   return;
                                // }
                                Entrants entrant = Entrants(
                                    id: athlete.importKey.toString(),
                                    number: athlete.raceNo.toString(),
                                    canFollow: false,
                                    isFollowed: false,
                                    name: athlete.fullName ?? 'Unknown',
                                    extra: '',
                                    profileImage: '',
                                    info:
                                        '${athlete.gender.name ?? ''} ${athlete.category.name ?? ''}\n${athlete.countryRepresenting.name ?? ''}',
                                    contest: athlete.overallPos,
                                    disRaceNo: athlete.raceNo.toString() ?? '',
                                    importKey: athlete.importKey);

                                Get.toNamed(Routes.athleteDetails, arguments: {
                                  AppKeys.athlete: entrant,
                                  'can_follow': false
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    child: Row(
                                      children: [
                                        if (controller.search == '')
                                          Container(
                                            width: 60,
                                            padding: const EdgeInsets.fromLTRB(
                                                15.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                                (index + 1)
                                                    .toString() /*'${athlete.netOverallPos ?? athlete.overallPos}'*/),
                                          ),
                                        Expanded(
                                            child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${athlete.fullName}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if ((athlete.countryRepresenting
                                                              .iso2 ??
                                                          '')
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 6.0),
                                                      child: CountryFlag
                                                          .fromCountryCode(
                                                        athlete
                                                            .countryRepresenting
                                                            .iso2
                                                            .toLowerCase(),
                                                        height: 16,
                                                        width: 22,
                                                        borderRadius: 4,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if ((athlete.splitName ?? '')
                                                  .isNotEmpty)
                                                Text(
                                                  athlete.splitName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        )),
                                        Container(
                                            width: 100,
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 0.0, 20.0, 0.0),
                                            child: Text(
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                              index != 0
                                                  ? '+${timeDiff.startsWith('00:') ? timeDiff.substring(3) : timeDiff}'
                                                  : '',
                                              textAlign: TextAlign.end,
                                            )),
                                      ],
                                    ),
                                  ),
                                  if (index <
                                      (controller.eventResult!.data.length - 1))
                                    Container(
                                      height: 1,
                                      color: Colors.grey[300],
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                    ),
                                ],
                              ),
                            );
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              (controller.eventResult?.data?.length ?? 0) +
                                  (controller.loadingMore.value ? 1 : 0))
                  ],
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: showScrollToTop,
            builder: (context, show, child) {
              if (!show) return SizedBox.shrink();
              return Positioned(
                bottom: 32,
                right: 24,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    controller.scrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Icon(Icons.keyboard_arrow_up, color: Colors.black),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
