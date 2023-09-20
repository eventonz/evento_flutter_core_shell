import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../common_components/no_data_found_layout.dart';
import 'event_results_controller.dart';

class EventResultsScreen extends StatelessWidget {
  const EventResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventResultsController());
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
                final eventResults = controller.eventResults;
                if (eventResults.isEmpty) {
                  return const Center(
                      child: NoDataFoundLayout(
                    errorMessage: 'No Result Found',
                  ));
                }
                return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: eventResults.length,
                    separatorBuilder: (_, i) {
                      return const Divider(
                        height: 1,
                      );
                    },
                    itemBuilder: (_, i) {
                      final result = eventResults[i];
                      return ListTile(
                        onTap: () => controller.decide(result),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              result.listTitle!.title!,
                              fontSize: 14,
                            ),
                            result.listTitle!.subtitle != null
                                ? AppText(
                                    result.listTitle!.subtitle!,
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  )
                                : const SizedBox()
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            result.listTitle!.thumbnail != null
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 4, 12, 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedNetworkImage(
                                        imageUrl: result.listTitle!.thumbnail!,
                                        placeholder: (_, val) => const Center(
                                            child: CircularProgressIndicator
                                                .adaptive()),
                                        errorWidget: (_, val, val2) =>
                                            const Center(
                                                child: NoDataFoundLayout(
                                          errorMessage: 'No Image Found',
                                        )),
                                        fit: BoxFit.cover,
                                        width: 14.w,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Icon(
                              Icons.arrow_circle_right_outlined,
                              size: 5.w,
                            ),
                          ],
                        ),
                      );
                    });
              } else if (controller.dataSnapshot.value == DataSnapShot.error) {
                return Center(
                    child: RetryLayout(onTap: controller.getEventResults));
              } else {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
            }),
          )
        ],
      ),
    );
  }
}
