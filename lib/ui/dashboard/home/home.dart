import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GetBuilder<HomeController>(
        builder: (controller) {
          return Stack(
            children: [
              // controller.videoPlayerController!.value.isInitialized
              //     ? SizedBox.expand(
              //         child: FittedBox(
              //           fit: BoxFit.cover,
              //           child: SizedBox(
              //             width: controller
              //                 .videoPlayerController!.value.size.width,
              //             height: controller
              //                 .videoPlayerController!.value.size.height,
              //             child: VideoPlayer(controller.videoPlayerController!),
              //           ),
              //         ),
              //       )
              //     : Container(),
              // AnimatedOpacity(
              //   opacity: controller.showVideo ? 0 : 1,
              //   duration: const Duration(milliseconds: 1000),
              //   curve: Curves.easeOutCubic,
              //   child: CachedNetworkImage(
              //     imageUrl: controller.imagelink,
              //     placeholder: (_, val) =>
              //         const Center(child: CircularProgressIndicator.adaptive()),
              //     errorWidget: (_, val, val2) => const Center(
              //         child: NoDataFoundLayout(
              //       errorMessage: 'No Image Found',
              //     )),
              //     width: double.infinity,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              CachedNetworkImage(
                imageUrl: controller.imagelink,
                placeholder: (_, val) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (_, val, val2) => const Center(
                    child: NoDataFoundLayout(
                  errorMessage: 'No Image Found',
                )),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          );
        },
      ),
    );
  }
}
