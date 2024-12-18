import 'dart:async';

import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/advert.dart';
import '../../../core/utils/api_handler.dart';
import '../../../core/utils/preferences.dart';

class AthletesController extends GetxController {
  late String athleteText;
  late String athletelabel;
  final TextEditingController searchTextEditController =
      TextEditingController();
  final searchText = ''.obs;
  late Athletes entrantsList;
  late List<Advert> advertList;
  final showFollowed = false.obs;
  final showAdvert = false.obs;
  final offset = 0.obs;
  int lastOffset = -1;
  final limit = 200;
  final DashboardController dashboardController = Get.find();
  final ScrollController scrollController = ScrollController();

  List<AppAthleteDb> accumulatedList = [];


  @override
  void onInit() {
    super.onInit();
    entrantsList = AppGlobals.appConfig!.athletes!;
    athleteText = AppHelper.setAthleteMenuText(entrantsList.text);
    checkAdvert(true);
    scrollController.addListener(onScroll);
  }

  void onScroll() {

    if((scrollController.position.maxScrollExtent-scrollController.offset) < 400) {
      if(lastOffset == offset.value) {
        offset.value = offset.value + limit;
        update();
      }
    }
  }

  void checkAdvert([bool impression = true]) {
    advertList = AppGlobals.appConfig!.adverts!;
    var advert = advertList
        .where((element) => element.type == AdvertType.banner)
        .firstOrNull;
    if (advert != null) {
      if (advert.frequency == AdvertFrequency.daily) {
        String lastOpen = Preferences.getString('last_banner_open', '');
        if (lastOpen != '') {
          DateTime dateTime = DateTime.parse(lastOpen);
          if (dateTime.day == DateTime.now().day) {
            showAdvert.value = false;
            return;
          }
        }
        Preferences.setString('last_banner_open', DateTime.now().toString());
      }
      showAdvert.value = true;
      if (impression) {
        trackEvent('impression');
      }
    } else {
      showAdvert.value = false;
    }
  }

  Future<void> trackEvent(String action) async {
    String url =
        'adverts/${advertList.where((element) => element.type == AdvertType.banner).first.id}';
    final res = await ApiHandler.postHttp(endPoint: url, body: {
      'action': action,
    });
    print(res.data);
  }

  void toggleFollowed() {
    showFollowed.value = !showFollowed.value;
    offset.value = 0;
    lastOffset = -1;
    accumulatedList = [];
    searchText.value = '';
    searchTextEditController.clear();
    update();
  }


  Future<void> searchAthletes(String val) async {
    searchText.value = val;
    offset.value = 0;
    lastOffset = -1;
    accumulatedList = [];
    update();
  }

  Stream<List<AppAthleteDb>> watchAthletes(String val) async* {

    StreamController<List<AppAthleteDb>> controller = StreamController<List<AppAthleteDb>>();

    if(lastOffset == offset.value) {
      controller.add(accumulatedList);
      yield* controller.stream;
      return;
    }
    print('list.length 2');

    await for (final list in DatabaseHandler.getAthletes(val, showFollowed.value, limit: limit, offset: offset.value)) {
      // Accumulate items into a list
      Future.delayed(const Duration(milliseconds: 100), () {
        lastOffset = offset.value;
      });
      print(list.length);
      print('list.length');
      for (final item in list) {
        int index = accumulatedList.indexWhere((element) => element.athleteId == item.athleteId);
        if(index == -1) {
          accumulatedList.add(item);
        } else {
          accumulatedList.removeAt(index);
          accumulatedList.insert(index, item);
        }
        // Yield a copy of the accumulated list
      }
      yield List.from(accumulatedList);
    }
    //yield* DatabaseHandler.getAthletes(val, showFollowed.value, limit: limit, offset: offset.value);
  }

  void clearSearchField() {
    searchText.value = '';
    searchTextEditController.clear();
    offset.value = 0;
    lastOffset = -1;
    accumulatedList = [];
    update();
  }

  void toAthleteDetails(AppAthleteDb entrant) async {
    Get.focusScope?.unfocus();
    Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: entrant});
  }

List<AppAthleteDb> sortFilterAthletes(List<AppAthleteDb> athletes) {
  athletes.sort((x, y) {
    int xValue = _parseRaceno(x.raceno);
    int yValue = _parseRaceno(y.raceno);
    return xValue.compareTo(yValue);
  });

  List<AppAthleteDb> assignedRaceNoAthletes = [];
  List<AppAthleteDb> unAssignedRaceNoAthletes = [];
  
  // Put unassigned racenumber athletes to the end of list 
  for (AppAthleteDb athlete in athletes) {
    if (athlete.athleteId == '9999999') {
      unAssignedRaceNoAthletes.add(athlete);
    } else {
      assignedRaceNoAthletes.add(athlete);
    }
  }
  
    return [...assignedRaceNoAthletes, ...unAssignedRaceNoAthletes];
  }
  int _parseRaceno(String raceno) {
  try {
    return int.parse(raceno);
  } catch (e) {
    return double.maxFinite.toInt(); // Assign a large value to non-integer raceno
  }
}

}
