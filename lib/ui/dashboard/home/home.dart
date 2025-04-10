import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:evento_core/core/utils/logger.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final AppConfig config = AppGlobals.appConfig!;

    return Obx(() => Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: controller.imagelink.value,
              placeholder: (_, val) =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              errorWidget: (_, val, val2) => Center(
                  child: NoDataFoundLayout(
                errorMessage: AppLocalizations.of(context)!.noImageFound,
              )),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                        itemBuilder: (_, index) {
                          var shortcut = config.home!.shortcuts!.small![index];

                          return GestureDetector(
                            onTap: () {
                              controller.openShortcut(
                                  shortcut.action!, shortcut.pageid);
                            },
                            child: Container(
                              width: Get.width * 0.39,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 30,
                                      height: 30,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: shortcut.backgroundGradient ==
                                                null
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? AppColors.accentDark
                                                : AppColors.accentLight)
                                            : null, // Apply color only if there's no gradient
                                        gradient: shortcut.backgroundGradient !=
                                                null
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppHelper.hexToColor(shortcut
                                                      .backgroundGradient!
                                                      .startColor),
                                                  AppHelper.hexToColor(shortcut
                                                      .backgroundGradient!
                                                      .endColor)
                                                ],
                                              )
                                            : null, // Apply gradient only if it's defined
                                      ),
                                      child: SvgPicture.asset(
                                        AppHelper.getSvg(shortcut.icon!),
                                        color: Colors.white,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${shortcut.title}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${shortcut.subtitle}',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        itemCount: config.home?.shortcuts?.small?.length ?? 0,
                        shrinkWrap: true),
                  ),
                  const SizedBox(height: 10),
                  if (config.home?.shortcuts?.large?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        height: 180,
                        child: ListView.builder(
                            itemBuilder: (_, index) {
                              var shortcut =
                                  config.home!.shortcuts!.large![index];
                              return GestureDetector(
                                onTap: () {
                                  controller.openShortcut(
                                      shortcut.action!, shortcut.pageid);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  width: Get.width * 0.7,
                                  height: 180,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: shortcut.image!
                                                  .startsWith('http')
                                              ? NetworkImage(shortcut.image!)
                                              : AssetImage(AppHelper.getImage(
                                                      shortcut.image! + '.png'))
                                                  as ImageProvider,
                                          fit: BoxFit.cover)),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount:
                                config.home?.shortcuts?.large?.length ?? 0),
                      ),
                    ),
                ],
              ),
            )
          ],
        ));
  }
}
