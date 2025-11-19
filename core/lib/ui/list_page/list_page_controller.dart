import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/event_results.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/bottom_sheet.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/routes/routes.dart';
import '../../core/utils/helpers.dart';

class ListPageController extends GetxController {
  late Items item;
  List<EventResult> eventResults = [];
  final dataSnapshot = DataSnapShot.loading.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    getEventResults();
  }

  void getEventResults() async {
    dataSnapshot.value = DataSnapShot.loading;
    try {
      final res = await ApiHandler.genericGetHttp(url: item.pages!.url!);
      final eventResultM = EventResultsM.fromJson(res.data);
      eventResults.clear();
      eventResults.addAll(eventResultM.eventResult!);
      dataSnapshot.value = DataSnapShot.loaded;
    } catch (e) {
      debugPrint(e.toString());
      eventResults.clear();
      dataSnapshot.value = DataSnapShot.error;
    }
  }

  void decide(EventResult result) {
    final type = result.detail?.type ?? '';
    if (type == 'content') {
      showInfoSheet(result);
    } else if (type == 'embed') {
      showWebSheet(result);
    } else if (type == 'eventomap') {
      Get.toNamed(Routes.eventoMap, arguments: {'source_id': result.detail?.endpoint});
    } else {
      ToastUtils.show('Something went wrong...');
    }
  }

  void showInfoSheet(EventResult result) {
    AppFixedBottomSheet(Get.context!).show(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
        child: Container(
          color: AppColors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: AppColors.white,
                  leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        FeatherIcons.x,
                        color: AppColors.primary,
                      )),
                  title: AppText(
                    result.listTitle!.title!,
                  ),
                ),
                CachedNetworkImage(
                  imageUrl: result.detail!.content!.image!,
                  placeholder: (_, val) =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  errorWidget: (_, val, val2) => Center(
                      child: NoDataFoundLayout(
                    errorMessage: AppLocalizations.of(Get.context!)!.noImageFound,
                  )),
                  fit: BoxFit.cover,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Html(data: result.detail!.content!.content!),
                        SizedBox(
                          height: 4.h,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showWebSheet(EventResult result) {
    final title = result.listTitle?.title;
    final url = result.detail!.embed!.url!;
    final linkType = result.detail!.embed!.linkType;
    AppHelper.showWebBottomSheet(title, url, linkType);
  }
}
