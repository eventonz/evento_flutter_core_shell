import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/models/miniplayer.dart';
import '../../core/utils/app_global.dart';
import 'package:youtube_player_flutter/src/player/youtube_player.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_controller.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_flags.dart';

class MiniPlayerController extends GetxController {
  late MiniPlayerConfig? miniPlayerConfig;

  late YoutubePlayerController controller;

  bool canGoBack = false;

  @override
  void onInit() {
    super.onInit();
    miniPlayerConfig = AppGlobals.appConfig!.miniPlayerConfig;
    controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(miniPlayerConfig!.ytUrl!)!,
        flags: YoutubePlayerFlags(
          showLiveFullscreenButton: false,
          isLive: miniPlayerConfig?.isLiveStream ?? false,
        ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    Future.delayed(const Duration(seconds: 5), () {
      canGoBack = true;
    });
  }
}