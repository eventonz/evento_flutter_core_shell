import 'package:evento_core/core/models/miniplayer.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:evento_core/ui/dashboard/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../youtube_player_flutter/src/player/youtube_player.dart';
import 'athletes/athletes_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  _play(MiniPlayerConfig config) {
    Get.toNamed(Routes.miniplayer, arguments: {
      'config' : config,
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final controllerA = Get.put(AthletesController());

    if(controller.miniPlayerConfig.value != null) {
      controller.setMiniPlayerConfig(AppGlobals.appConfig!.miniPlayerConfig);
    }

    print("hello");

    Get.put(TrackingController());
    return Scaffold(
        body: Stack(
          children: [
            Obx(() => controller.selMenu.value!.view),
            Obx(() => Visibility(
                  visible: controller.selMenu.value == controller.menus.first &&
                      AppGlobals.appEventConfig.multiEventListId != null,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 5.5.w,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? AppColors.black.withOpacity(0.8)
                                : AppColors.white.withOpacity(0.8),
                        child: IconButton(
                          onPressed: controller.goBack,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.accentDark
                                  : AppColors.accentLight,
                          icon: const Icon(Icons.arrow_circle_left_outlined),
                        ),
                      ),
                    ),
                  ),
                )),
            if(controller.miniPlayerConfig.value != null)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Obx(() => controller.miniPlayerConfig.value == null ? Container() : Miniplayer(backgroundColor: Colors.white, minHeight: 60, maxHeight: 265, builder: (height, percentage) {
                  if(height == 60) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Image.network('https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(controller
                              .miniPlayerConfig.value!
                              .ytUrl!)}/0.jpg', width: 91, height: 51, fit: BoxFit
                              .cover,),
                          Expanded(child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text('Play ${controller.miniPlayerConfig.value!.title ?? ''}',
                                      style: TextStyle(
                                        fontSize: 13,
                                      ), maxLines: 2, overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                              )
                            ],
                          )),
                          IconButton(onPressed: () {
                            _play(controller.miniPlayerConfig.value!);
                          }, icon: Icon(
                            Icons.play_arrow_outlined, size: 30,)),
                          IconButton(onPressed: () {
                            controller.setMiniPlayerConfig(null);
                          }, icon: Icon(
                              Icons.close, size: 30)),
                        ],
                      ),
                    );
                  }
                  if(height == 265) {
                    return Stack(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  'https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(controller
                                      .miniPlayerConfig.value!
                                      .ytUrl!)}/0.jpg', width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.6, height: 140, fit: BoxFit
                                    .cover,),
                              ),
                              const SizedBox(height: 4),
                              IconButton(onPressed: () {
                                _play(controller.miniPlayerConfig.value!);
                              }, icon: Icon(
                                Icons.play_arrow_outlined, size: 34,)),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('Play ${controller.miniPlayerConfig.value!.title ?? ''}',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: IconButton(onPressed: () {
                            controller.setMiniPlayerConfig(null);
                          }, icon: Icon(
                            Icons.close, size: 28,)),
                        ),
                      ],
                    );
                  }
                  return Container();
                }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNav());
  }
}
