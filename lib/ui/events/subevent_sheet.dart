import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/subevent_tile.dart.dart';
import 'package:evento_core/ui/events/events_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubEventSheet extends StatelessWidget {
  const SubEventSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventsController controller = Get.find();
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: Get.back,
              icon: const Icon(
                FeatherIcons.x,
                color: AppColors.white,
              ),
            ),
            Expanded(
                child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.darkBlack
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [AppStyles.tileDeepShadow]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CachedNetworkImage(
                        imageUrl: controller.selEvent.header!,
                        placeholder: (_, val) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (_, val, val2) => const Center(
                            child: NoDataFoundLayout(
                          errorMessage: 'No Image Found',
                        )),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 16.h,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: controller.selEvent.subEvents!.length,
                        separatorBuilder: (_, i) {
                          return const Divider(
                            height: 0,
                          );
                        },
                        itemBuilder: (_, i) {
                          final subEvent = controller.selEvent.subEvents![i];
                          return SubEventTile(
                              onTap: () => controller.selectEvent(subEvent),
                              subEvent: subEvent);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
