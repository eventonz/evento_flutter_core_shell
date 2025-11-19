// ignore_for_file: invalid_use_of_protected_member

import 'package:evento_core/core/models/schedule.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/utils/enums.dart';
import 'package:evento_core/core/utils/date_extensions.dart';
import 'schedule_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleController());
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
        backgroundColor:
            isLightMode ? AppColors.greyLighter : AppColors.darkBlack,
        appBar: AppBar(
          backgroundColor:
              isLightMode ? AppColors.greyLighter : AppColors.darkBlack,
          surfaceTintColor:
              isLightMode ? AppColors.greyLighter : AppColors.darkBlack,
          shadowColor:
              isLightMode ? Colors.black.withOpacity(0.1) : Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
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
                  final scheduleItems = controller.scheduleItemsFiltered.value;
                  final tags = controller.tags;
                  if (scheduleItems.isEmpty && tags.isEmpty) {
                    return Center(
                        child: NoDataFoundLayout(
                      errorMessage: AppLocalizations.of(context)!.noDataFound,
                    ));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 0.5.h,
                      ),
                      SizedBox(
                        height: 5.6.h,
                        child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            itemCount: tags.length,
                            separatorBuilder: (_, i) {
                              return SizedBox(
                                width: 2.5.w,
                              );
                            },
                            itemBuilder: (_, i) {
                              final tag = tags[i];
                              return Obx(() {
                                return GestureDetector(
                                  onTap: () => controller.selectTag(tag),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                        color: tag == controller.selTag.value
                                            ? AppColors.primary
                                            : isLightMode
                                                ? AppColors.greyLight
                                                    .withOpacity(0.5)
                                                : AppColors.grey
                                                    .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Center(
                                      child: AppText(
                                        tag,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: tag == controller.selTag.value
                                            ? AppColors.white
                                            : isLightMode
                                                ? AppColors.black
                                                : AppColors.white,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                      ),
                      Expanded(
                        child: scheduleItems.isEmpty
                            ? Center(
                                child: NoDataFoundLayout(
                                  errorMessage: AppLocalizations.of(context)!
                                      .noScheduleFound,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 0),
                                itemCount: scheduleItems.length,
                                itemBuilder: (_, i) {
                                  final events = scheduleItems[i];
                                  return Visibility(
                                    visible:
                                        events.scheduleDataItems.isNotEmpty,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          child: AppText(
                                            events.date.withDateFormat(
                                                format: 'E, dd MMMM'),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isLightMode
                                                ? AppColors.darkBlack
                                                : AppColors.white,
                                          ),
                                        ),
                                        // Card container for schedule items
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.white
                                                    : AppColors.darkBlack,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          padding: EdgeInsets.zero,
                                          child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemCount: events
                                                  .scheduleDataItems.length,
                                              itemBuilder: (_, i) {
                                                final item =
                                                    events.scheduleDataItems[i];

                                                return Column(
                                                  children: [
                                                    if (i > 0)
                                                      Divider(
                                                          indent: 10,
                                                          height: 1,
                                                          thickness: .5,
                                                          color: isLightMode
                                                              ? AppColors
                                                                  .darkgrey
                                                                  .withOpacity(
                                                                      0.2)
                                                              : AppColors
                                                                  .greyLight
                                                                  .withOpacity(
                                                                      0.2)),
                                                    ScheduleTile(
                                                      onTap: () => controller
                                                          .showEventDetails(
                                                              item),
                                                      item: item,
                                                      isFirst: i == 0,
                                                      isLast: i ==
                                                          events.scheduleDataItems
                                                                  .length -
                                                              1,
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                  // return ScheduleTile(
                                  //     onTap: () => controller.showEventDetails(
                                  //         item.scheduleDataItems),
                                  //     item: item.scheduleDataItems);
                                }),
                      ),
                    ],
                  );
                } else if (controller.dataSnapshot.value ==
                    DataSnapShot.error) {
                  return Center(
                      child: RetryLayout(onTap: controller.getScheduleData));
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

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    Key? key,
    required this.onTap,
    required this.item,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);
  final ScheduleDataItems item;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  String getEventTimings() {
    String timings = '';
    final startTime = item.startTime!.withDateFormat(format: 'HH:mm a');
    final endTime = item.endTime!.withDateFormat(format: 'HH:mm a');
    if (endTime.isNotEmpty) {
      timings = '$startTime - $endTime';
    } else {
      timings = startTime;
    }

    return timings;
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: item.highlighted ?? false
                    ? AppColors.primary
                    : Colors.transparent,
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isFirst ? 12 : 0),
              topRight: Radius.circular(isFirst ? 12 : 0),
              bottomLeft: Radius.circular(isLast ? 12 : 0),
              bottomRight: Radius.circular(isLast ? 12 : 0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.title!,
                      maxLines: 2,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                      color:
                          isLightMode ? AppColors.darkBlack : AppColors.white,
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    AppText(
                      getEventTimings(),
                      fontSize: 12,
                      color: isLightMode
                          ? AppColors.darkgrey
                          : AppColors.splitLightGrey,
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    AppText(
                      item.location!.title!,
                      fontSize: 12,
                      color: isLightMode
                          ? AppColors.darkgrey
                          : AppColors.splitLightGrey,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_circle_right_outlined,
                color: AppColors.primary,
                size: 6.w,
              ),
            ],
          ),
        ));
  }
}
