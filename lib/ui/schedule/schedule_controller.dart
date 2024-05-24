import 'dart:io';

import 'package:collection/collection.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/schedule.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/date_extensions.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/common_components/bottom_sheet.dart';
import 'package:evento_core/ui/schedule/event_map_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class ScheduleController extends GetxController {
  final accessToken =
      'pk.eyJ1IjoiZXZlbnRvbnoiLCJhIjoiY2x2enQ4a3FuMDdmaTJxcGY1MG1ldjh6diJ9.72FtQjCQ4uUiyFyzWCh5hA';
  final terrainStyle = 'cl8bcmdxd001c15p9c5mua0jk';
  late Items item;
  List<ScheduleDataItems> scheduleDataItems = [];
  List<String> tags = [];
  Map<String, List<ScheduleDataItems>> groupedEvents = {};
  final scheduleItemsFiltered = <ScheduleItem>[].obs;
  final selTag = ''.obs;
  final dataSnapshot = DataSnapShot.loading.obs;
  final currentPageIndex = 0.obs;
  late ScheduleDataItems eventDetails;
  late LatLng? latLng;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    getScheduleData();
  }

  void getScheduleData() async {
    dataSnapshot.value = DataSnapShot.loading;
    try {
      final res = await ApiHandler.genericGetHttp(url: item.schedule!.url!);

      final scheduleM = ScheduleM.fromJson(res.data);
      scheduleDataItems = scheduleM.schedule!.items!;
      tags = scheduleM.schedule!.tags!;
      tags.insert(0, 'All');
      // tags.insert(1, 'Today');

      selectTag(tags.first);
      dataSnapshot.value = DataSnapShot.loaded;
    } catch (e) {
      debugPrint(e.toString());
      scheduleDataItems.clear();
      dataSnapshot.value = DataSnapShot.error;
    }
  }

  void refreshList() {
    scheduleItemsFiltered.clear();
    groupedEvents = groupBy(scheduleDataItems,
        (ScheduleDataItems item) => item.datetime!.split('T').first);
    groupedEvents.forEach((key, value) {
      scheduleItemsFiltered
          .add(ScheduleItem(date: key, scheduleDataItems: value));
    });
  }

  void selectTag(String tag) {
    selTag.value = tag;
    refreshList();
    if (tag != 'All') {
      if (tag == 'Today') {
        final date = DateTime.now().toIso8601String().split('T').first;
        scheduleItemsFiltered.removeWhere((element) => element.date != date);
      } else {
        for (ScheduleItem scheduleItem in scheduleItemsFiltered) {
          scheduleItem.scheduleDataItems
              .removeWhere((element) => !element.tags!.contains(tag));
        }
      }
    }
    scheduleItemsFiltered.refresh();
  }

  void showWebSheet(String url) {
    AppHelper.showWebBottomSheet(null, url);
  }

  String getEventTimings() {
    String timings = '';
    final startTime = eventDetails.startTime!.withDateFormat(format: 'HH:mm a');
    final endTime = eventDetails.endTime!.withDateFormat(format: 'HH:mm a');
    if (endTime.isNotEmpty) {
      timings = '$startTime - $endTime';
    } else {
      timings = startTime;
    }

    return timings;
  }

  void showEventDetails(ScheduleDataItems item) async {
    eventDetails = item;
    if (item.location!.coordinate != null) {
      final coordinate = item.location!.coordinate!;
      latLng = LatLng(coordinate.latitude!, coordinate.longitude!);
    } else {
      latLng = null;
    }
    await AppFixedBottomSheet(Get.context!, enableDrag: true)
        .show(child: EventMapSheet(latLng: latLng));
  }

}

class ScheduleItem {
  ScheduleItem({
    required this.date,
    required this.scheduleDataItems,
  });
  final String date;
  final List<ScheduleDataItems> scheduleDataItems;
}
