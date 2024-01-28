import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/event_tile.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'events_controller.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());
    return Scaffold(
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          expandedHeight: 10.h,
          floating: true,
          pinned: true,
          snap: true,
          stretch: true,
          flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            var top = constraints.biggest.height;
            return FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              title: AnimatedOpacity(
                opacity: top > 120 ? 0 : 1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: AppText(
                  '',
                  style: AppStyles.appBarTitle.copyWith(color: AppColors.black),
                ),
              ),
              background: Stack(
                children: [
                  // Positioned.fill(
                  //   child: CachedNetworkImage(
                  //     imageUrl: controller.headerImage,
                  //     placeholder: (_, val) => const Center(
                  //         child: CircularProgressIndicator.adaptive()),
                  //     errorWidget: (_, val, val2) => const Center(
                  //         child: NoDataFoundLayout(
                  //       errorMessage: 'No Image Found',
                  //     )),
                  //     width: double.infinity,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Positioned.fill(
                      child: ColoredBox(
                    color: AppHelper.hexToColor(controller.headerColor),
                  )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CachedNetworkImage(
                        imageUrl: controller.headerLogo,
                        placeholder: (_, val) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (_, val, val2) => const Center(
                            child: NoDataFoundLayout(
                          errorMessage: 'No Image Found',
                        )),
                        width: 60.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: controller.events.length,
                    separatorBuilder: (_, i) {
                      return const SizedBox(
                        height: 16,
                      );
                    },
                    itemBuilder: (_, i) {
                      final event = controller.events[i];
                      return EventTile(
                          onTap: () => controller.selectEvent(event),
                          event: event);
                    },
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}
