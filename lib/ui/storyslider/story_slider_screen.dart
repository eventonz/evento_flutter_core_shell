import 'dart:io';

import 'package:evento_core/core/models/storyslider.dart';
import 'package:evento_core/social_media_widgets/instagram_story_swipe.dart';
import 'package:evento_core/ui/storyslider/story_slider_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_video_player/cached_video_player.dart';

class StorySliderScreen extends StatelessWidget {
  const StorySliderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StorySliderController());



    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => Stack(
          children: [
            controller.sliders.isNotEmpty ?
            InstagramStorySwipe(
                instagramSwipeController: controller.swipeController,
                children: controller.sliders.map((e) =>  Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: SliderItem(item: e),
                )).toList()) : Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            SafeArea(
              child: Row(
                children: [
                  const SizedBox(width: 20,),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(3),

                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 24),
                    ),
                  ),
                  const Spacer(),
              if(controller.sliders.isNotEmpty)
              InkWell(
                onTap: () {
                  launchUrl(Uri.parse('${controller.sliders[controller.position.value].openUrl}'), mode: LaunchMode.externalApplication);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Image.asset('packages/evento_core/assets/images/${controller.sliders[controller.position.value].type}.png', width: 21, color: Theme.of(context).iconTheme.color),
                )),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () async {
                      controller.setSharing(true);
                      var response = await get(Uri.parse(controller.sliders[controller.position.value].image!)); // <--2
                      var documentDirectory = await getApplicationDocumentsDirectory();
                      var firstPath = documentDirectory.path + "/images";
                      var filePathAndName = documentDirectory.path + '/images/${controller.sliders[controller.position.value].image!.split('/').last}';
                      //comment out the next three lines to prevent the image from being saved
                      //to the device to show that it's coming from the internet
                      await Directory(firstPath).create(recursive: true); // <-- 1
                      File file = new File(filePathAndName);             // <-- 2
                      file.writeAsBytesSync(response.bodyBytes);         // <-- 3
                      controller.setSharing(false);
                      Share.shareXFiles(
                          [XFile(file.path)],
                          text: '${controller.sliders[controller.position.value].openUrl}\n${controller.sliders[controller.position.value].video}',
                      );

                    },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: controller.sharing.value ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                      ),
                    ),
                  ) : Image.asset('packages/evento_core/assets/images/share.png', width: 21, color: Theme.of(context).iconTheme.color,),
                )),
                  const SizedBox(width: 20,),
                ],
              ),
            ),
            if(controller.sliders.isNotEmpty)
            Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Obx(() {
                  return Center(
                    child: SmoothPageIndicator(
                        controller: controller.swipeController.pageController,  // PageController
                        count:  controller.sliders.length,
                        effect:  SwapEffect(
                          dotHeight: 30,
                          dotWidth: 30,

                        ),  // your preferred effect
                        onDotClicked: (index){
                          controller.position.value = index;
                        }
                    ),
                  );
                  }
                )),
          ],
        ),
      ),
    );
  }
}

class SliderItem extends StatefulWidget {

  final StorySlider item;
  const SliderItem({super.key, required this.item});

  @override
  State<SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<SliderItem> {

  CachedVideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
    if(widget.item.video != null) {
      videoPlayerController =
      CachedVideoPlayerController.network((widget.item.video!))
        ..initialize().then((value) {
          videoPlayerController?.setLooping(true);
          videoPlayerController?.play();
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          image: widget.item.video == null ? DecorationImage(image: NetworkImage(widget.item.image!), fit: BoxFit.cover) : null,
        ),
        child: Container(
            margin: const EdgeInsets.only(),
            child: widget.item.video == null ? SizedBox() : CachedVideoPlayer(
              videoPlayerController!,
            )
        ),
      ),
    );
  }
}

