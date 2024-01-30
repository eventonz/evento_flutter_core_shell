import 'package:evento_core/social_media_widgets/insta_swipe_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../core/models/app_config.dart';
import '../../core/models/storyslider.dart';
import '../../core/utils/api_handler.dart';
import '../../core/utils/keys.dart';

class StorySliderController extends GetxController {

  InstagramSwipeController swipeController = InstagramSwipeController();

  Rx<int> position = Rx(0);

  RxBool sharing = RxBool(false);

  double d = 0;

  RxList<StorySlider> sliders = RxList([]);


  @override
  void onInit() {
    super.onInit();
    getSlides();
  }

  void setSharing(bool sharing) {
    this.sharing.value = sharing;
    update();
  }

  getSlides() async {
    Items item = Get.arguments[AppKeys.moreItem];
    final res = await ApiHandler.genericGetHttp(url: item.storySlider!.url!);
    sliders.value = (res.data['items'] as List).map((e) {
      var slider = StorySlider.fromJson(e);
      if(slider.video != null) {
        slider.videoPlayerController = Rx(VideoPlayerController.networkUrl(Uri.parse(slider.video!))..initialize().then((value) {
          update();
        }));
      }

      return slider;
    }).toList();
    update();

    if(sliders[0].videoPlayerController != null) {
      sliders[0].videoPlayerController!.value.play();
      sliders[0].videoPlayerController!.value.setLooping(true);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      swipeController.pageController.addListener(() {

        List.generate(sliders.length, (index) {
          sliders[index].videoPlayerController?.value.pause();
        });

        double pos = (swipeController.pageController.page ?? 0.0);
        position.value = pos > d ? pos.ceil() : pos.floor();
        d = pos;

        sliders[position.value].videoPlayerController?.value.seekTo(Duration.zero);
        sliders[position.value].videoPlayerController?.value.play();
        sliders[position.value].videoPlayerController?.value.setLooping(true);
        update();
      });
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    sliders.forEach((element) {
      if(element.videoPlayerController != null) {
        element.videoPlayerController!.value.dispose();
      }
    });
  }
}