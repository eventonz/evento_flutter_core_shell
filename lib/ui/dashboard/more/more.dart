import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/ui/common_components/more_menu_tile.dart';
import 'package:evento_core/ui/common_components/more_menu_title.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/models/storyslider.dart';
import '../../../core/utils/api_handler.dart';
import 'more_controller.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MoreController controller = Get.find();
    print( controller.moreDetails.items?.map((e) => e.id));
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const AppText(
            'Menu',
            style: AppStyles.appBarTitle,
          ),
          actions: [
            IconButton(
              
                onPressed: controller.toSettingsScreen,
                icon: const Icon(
                  FeatherIcons.settings,
                ))
          ],
        ),
        body: GetBuilder<MoreController>(builder: (_) {
          return SmartRefresher(
              enablePullDown: true,
              physics: const BouncingScrollPhysics(),
              header: const MaterialClassicHeader(),
              controller: controller.refreshController,
              onRefresh: controller.doRrefresh,
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = const Text("pull up load");
                  } else if (mode == LoadStatus.loading) {
                    body = const CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = const Text("Load Failed!Click retry!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = const Text("release to load more");
                  } else {
                    body = const Text("No more Data");
                  }
                  return SizedBox(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.moreDetails.items!.length + 1,
                  separatorBuilder: (_, i) {
                    return Divider(
                      height: 1,
                      thickness: .5,
                      color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.darkgrey :AppColors.greyLight,
                    );
                  },
                  itemBuilder: (_, i) {
                    if (i == controller.moreDetails.items!.length) {
                      Items item2 = Items(
                        type: 'results',
                        supplier: 'sportsplits',
                        title: '2024 Results 2',
                        sportSplitsRaceId: 18409,
                        id: 14214,
                        icon: 'terrain',
                        linkToDetail: true
                      );

                      Items item = Items(
                        type: 'results',
                        supplier: 'sportsplits',
                        title: '2024 Results',
                        sportSplitsRaceId: 18507,
                        id: 1704,
                        icon: 'terrain',
                      );

                      return SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          MoreMenuTile(
                              onTap: () => controller.decideNextView(item),
                              item: item),
                          MoreMenuTile(
                              onTap: () => controller.decideNextView(item2),
                              item: item2),
                        ],
                      );
                      return const SizedBox();
                    }
                    final item = controller.moreDetails.items![i];
                    if (item.type == 'divider') {
                      return MoreMenuTitle(item: item);
                    }
                    return MoreMenuTile(
                        onTap: () => controller.decideNextView(item),
                        item: item);
                  }));
        }));
  }
}
