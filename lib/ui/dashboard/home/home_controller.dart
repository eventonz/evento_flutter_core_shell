import 'package:evento_core/core/utils/app_global.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController {
  late String imagelink;
  late VideoPlayerController? videoPlayerController;
  bool showVideo = false;

  @override
  void onInit() {
    super.onInit();
    videoPlayerController = null;
    imagelink = AppGlobals.appConfig!.home!.image!;
  }

  void initVideo() {
    videoPlayerController =
        VideoPlayerController.asset('assets/videos/home_video.mp4')
          ..initialize().then((_) {});
    startFade();
  }

  @override
  void onClose() {
    super.onClose();
    stopVideo();
    videoPlayerController?.removeListener(() {});
    videoPlayerController = null;
  }

  void startFade() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (videoPlayerController == null) {
      return;
    }
    videoPlayerController?.setVolume(0);
    videoPlayerController?.setLooping(true);
    videoPlayerController?.play();
    showVideo = true;
    update();
  }

  void stopVideo() async {
    showVideo = false;
    videoPlayerController?.pause();
    videoPlayerController?.seekTo(const Duration(seconds: 0));
  }
}
