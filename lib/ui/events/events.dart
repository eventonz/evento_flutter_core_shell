import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/event_tile.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'events_controller.dart';
import 'package:evento_core/core/utils/app_global.dart';

class EventsScreen extends StatelessWidget {
  
  const EventsScreen({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventsController());

    final appEventConfig = AppGlobals.appEventConfig;

    return Scaffold(
      body: PageStorage(
        bucket: controller.bucket,
        child: CustomScrollView(
            key: const PageStorageKey('eventsScrollPosition'),
            controller: controller.scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppHelper.hexToColor(controller.headerColor),
                surfaceTintColor: AppHelper.hexToColor(controller.headerColor),
                shadowColor: AppHelper.hexToColor(controller.headerColor),
                expandedHeight: controller.searchBar ? 20.h : 13.h,
                floating: false,
                pinned: true,
                snap: false,
                stretch: true,
                flexibleSpace: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.zero,
                    collapseMode: CollapseMode.parallax,
                    stretchModes: const [StretchMode.zoomBackground],
                    title: AnimatedOpacity(
                      opacity: top > 120 ? 0 : 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: top > 120 ? SizedBox() : !controller.searchBar ? SizedBox() : Container(
                        decoration:  BoxDecoration(
                          color: AppHelper.hexToColor(controller.headerColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, bottom: 10),
                          child: SafeArea(
                            bottom: false,
                            child: TextField(
                              controller: controller.searchController,
                              onChanged: (val) {
                                controller.onSearch(val);
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  color: appEventConfig.searchbarcolor ?? Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(CupertinoIcons.search,
                                    color: appEventConfig.searchbarcolor ?? Colors.white, size: 18),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: appEventConfig.searchbarcolor ?? Colors.white,
                                  width: .5,
                                )),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: appEventConfig.searchbarcolor ?? Colors.white,
                                  width: .5,
                                )),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: appEventConfig.searchbarcolor ?? Colors.white,
                                  width: .5,
                                )),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                 background: Stack(
                            children: [
                              Positioned.fill(
                                child: ColoredBox(
                                  color: AppHelper.hexToColor(controller.headerColor),
                                ),
                              ),
                              SafeArea(
                                bottom: false, // Prevents unwanted bottom padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width, // Full width
                                    height: MediaQuery.of(context).size.width / 4,
                                    child: CachedNetworkImage(
                                      imageUrl: controller.headerLogo,
                                      placeholder: (_, val) => const Center(
                                        child: CircularProgressIndicator.adaptive(),
                                      ),
                                      errorWidget: (_, val, val2) => const Center(
                                        child: NoDataFoundLayout(errorMessage: 'No Image Found'),
                                      ),
                                      fit: BoxFit.cover, // Ensures full width with no empty spaces
                                    ),
                                  ),
                                    if (controller.searchBar)
                                    const SizedBox(height: 12),
                                    if (controller.searchBar)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0, bottom: 8.0),
                                        child: TextField(
                                          controller: controller.searchController,
                                          onChanged: (val) {
                                            controller.onSearch(val);
                                          },
                                          style:  TextStyle(
                                            color: appEventConfig.searchbarcolor ?? Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                          decoration:  InputDecoration(
                                            hintText: 'Search...',
                                            hintStyle: TextStyle(
                                              color: appEventConfig.searchbarcolor ?? Colors.white,
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                            ),
                                            prefixIcon: Icon(CupertinoIcons.search,
                                                color: appEventConfig.searchbarcolor ?? Colors.white, size: 18),
                                            contentPadding:
                                                EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                              color: appEventConfig.searchbarcolor ?? Colors.white,
                                              width: 1,
                                            )),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                              color: appEventConfig.searchbarcolor ?? Colors.white,
                                              width: 1,
                                            )),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                              color: appEventConfig.searchbarcolor ?? Colors.white,
                                              width: 1,
                                            )),
                                          ),
                                        ),
                                      ),
                                  ],
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
                        Obx(
                          () => ListView.separated(
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
                              print('event ${event.id}');
                              return EventTile(
                                  onTap: () => controller.selectEvent(event),
                                  event: event);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
