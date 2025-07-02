import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/res/app_theme.dart';
import 'package:evento_core/l10n/app_localizations.dart';
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
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
        backgroundColor: isLightMode
    
            ? AppThemeColors.darkBackground :
            AppThemeColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isLightMode
              ? AppThemeColors.darkBackground
              : AppThemeColors.lightBackground,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          automaticallyImplyLeading: false,
          title: AppText(
            AppLocalizations.of(context)!.menubutton,
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
                    body = Text(
                        AppLocalizations.of(context)!.loadFailedClickRetry);
                  } else if (mode == LoadStatus.canLoading) {
                    body =
                        Text(AppLocalizations.of(context)!.releaseToLoadMore);
                  } else {
                    body = Text(AppLocalizations.of(context)!.noMoreData);
                  }
                  return SizedBox(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              child: _buildCardGroups(context, controller));
        }));
  }

  Widget _buildCardGroups(BuildContext context, MoreController controller) {
    final items = controller.moreDetails.items!;
    final List<Widget> widgets = [];

    List<Items> currentGroup = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      if (item.type == 'divider') {
        // If we have items in the current group, create a card for them
        if (currentGroup.isNotEmpty) {
          widgets.add(_buildCard(context, currentGroup, controller));
          currentGroup = [];
        }

        // Add the divider title (not in a card)
        widgets.add(MoreMenuTitle(item: item));
      } else {
        // Add item to current group
        currentGroup.add(item);
      }
    }

    // Don't forget the last group if there are items
    if (currentGroup.isNotEmpty) {
      widgets.add(_buildCard(context, currentGroup, controller));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: widgets.length,
      separatorBuilder: (_, i) => const SizedBox(height: 16),
      itemBuilder: (_, i) => widgets[i],
    );
  }

  Widget _buildCard(
      BuildContext context, List<Items> items, MoreController controller) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: AppThemeStyles.cardDecoration(context),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              MoreMenuTile(
                onTap: () => controller.decideNextView(item),
                item: item,
              ),
              // Add divider between items (except for the last one)
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: isLightMode
                      ? AppColors.darkgrey.withOpacity(0.2)
                      : AppColors.greyLight.withOpacity(0.2),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
