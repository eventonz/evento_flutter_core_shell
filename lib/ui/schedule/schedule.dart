// ignore_for_file: invalid_use_of_protected_member

import 'package:evento_core/core/models/schedule.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
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
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
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
                    return const Center(
                        child: NoDataFoundLayout(
                      errorMessage: 'No Data Found',
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
                                            : AppColors.greyLight
                                                .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Center(
                                      child: AppText(
                                        tag,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: tag == controller.selTag.value
                                            ? AppColors.white
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                      ),
                      Expanded(
                        child: scheduleItems.isEmpty
                            ? const Center(
                                child: NoDataFoundLayout(
                                  errorMessage: 'No Schedule found',
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                                        SizedBox(
                                          height: 0.4.h,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          child: AppText(
                                            events.date.withDateFormat(
                                                format: 'E, dd MMMM'),
                                            fontSize: 18,
                                          ),
                                        ),
                                        ListView.separated(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: events
                                                    .scheduleDataItems.length +
                                                2,
                                            separatorBuilder: (_, i) {
                                              return Divider(
                                            indent:10,
                                            height: 1,
                                            thickness: .5,
                                            color:Theme.of(context).brightness == Brightness.light
                                                    ? AppColors.darkgrey
                                                    : AppColors.greyLight);
                                            },
                                            itemBuilder: (_, i) {
                                              if (i == 0 ||
                                                  i ==
                                                      events.scheduleDataItems
                                                              .length +
                                                          1) {
                                                return const SizedBox.shrink();
                                              }
                                              final item = events
                                                  .scheduleDataItems[i - 1];

                                              return ScheduleTile(
                                                  onTap: () => controller
                                                      .showEventDetails(item),
                                                  item: item);
                                            }),
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
  const ScheduleTile({Key? key, required this.onTap, required this.item})
      : super(key: key);
  final ScheduleDataItems item;
  final VoidCallback onTap;

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
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                  width: 2.w,
                  color: item.highlighted ?? false
                      ? AppColors.primary
                      : AppColors.transparent),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 82.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.title!,
                      maxLines: 2,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    AppText(
                      getEventTimings(),
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.greyLight
                                : AppColors.grey,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    AppText(
                      item.location!.title!,
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
