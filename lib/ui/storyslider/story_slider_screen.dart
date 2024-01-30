import 'package:dots_indicator/dots_indicator.dart';
import 'package:evento_core/social_media_widgets/instagram_story_swipe.dart';
import 'package:evento_core/ui/storyslider/story_slider_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
                children: controller.sliders.map((e) =>  Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(e.image!), fit: BoxFit.cover),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 30,
                      bottom: 30,
                    ),
                    child: Container(

                    )
                  ),
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
                    onTap: () {
                      Share.share(
                          'Hello, this is just a text: ${controller.sliders[controller.position.value].openUrl}\n${controller.sliders[controller.position.value].image}',
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
                  child: Image.asset('packages/evento_core/assets/images/share.png', width: 21, color: Theme.of(context).iconTheme.color,),
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
                    return DotsIndicator(
                      decorator: DotsDecorator(
                        size: Size(30, 30),
                        activeSize: Size(30, 30),
                      ),
                      dotsCount: controller.sliders.length, position: controller.position.value,);
                  }
                )),
          ],
        ),
      ),
    );
  }
}
