import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    return Obx(() => CachedNetworkImage(
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
        ));
  }
}
