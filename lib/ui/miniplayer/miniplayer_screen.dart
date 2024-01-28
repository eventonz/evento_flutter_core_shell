import 'package:evento_core/ui/miniplayer/miniplayer_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MiniPlayerScreen extends StatelessWidget {
  const MiniPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(MiniPlayerController());
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: Scaffold(
        body: YoutubePlayerBuilder(
          onExitFullScreen: () {
            if(!controller.canGoBack) {
              //controller.canGoBack = true;
              return;
            }
            Get.back();
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          },
          builder: (_, widget) {
            return Container();
          },
          player: YoutubePlayer(
              topActions: [
                SafeArea(child: IconButton(onPressed: () {
                  Get.back();
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                }, icon: const Icon(Icons.expand_circle_down_outlined, color: Colors.white,)))
              ],
              controller: controller.controller),
        ),
      ),
    );
  }
}
