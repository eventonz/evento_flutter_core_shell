import 'dart:async';

import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../core/models/advert.dart';
import '../../../core/utils/api_handler.dart';
import '../../../core/utils/preferences.dart';

class AthletesController extends GetxController {
  late String athleteText;
  late String athletelabel;
  final TextEditingController searchTextEditController =
      TextEditingController();

  final FocusNode focusNode = FocusNode();
  final searchText = ''.obs;
  late Athletes entrantsList;
  late List<Advert> advertList;
  final showFollowed = true.obs;
  final loading = true.obs;
  final loadingMore = false.obs;
  final showAdvert = false.obs;
  final offset = 0.obs;
  int lastOffset = -1;
  int page = 1;
  int lastPage = 1;
  final limit = 200;
  final DashboardController dashboardController = Get.find();
  final ScrollController scrollController = ScrollController();
  final ScrollController searchScrollController = ScrollController();

  List<AppAthleteDb> accumulatedList = [];
  List<Entrants> searchAccumulatedList = [];

  Map pagination = {};

  @override
  void onInit() {
    super.onInit();
    entrantsList = AppGlobals.appConfig!.athletes!;
    athleteText = AppHelper.setAthleteMenuText(entrantsList.text);
    checkAdvert(true);
    scrollController.addListener(onScroll);
    searchScrollController.addListener(onSearchScroll);
  }

  void onScroll() {
    if ((scrollController.position.maxScrollExtent - scrollController.offset) <
        400) {
      if (lastOffset == offset.value) {
        offset.value = offset.value + limit;
        update();
      }
    }
  }

  void onSearchScroll() {
    if ((searchScrollController.position.maxScrollExtent -
            searchScrollController.offset) <
        400) {
      if (lastPage == page) {
        page = page + 1;
        update();
        if (page <= (pagination['totalPages'] ?? 1)) {
          getAthletes(searchText.value);
        }
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
    loading.value = true;
    page = 1;
    lastPage = 1;
    lastOffset = -1;
    accumulatedList = [];
    searchAccumulatedList = [];
    getAthletes(val);
    update();
  }

  Future<void> followAthlete(Entrants athelete) async {
    if (AppGlobals.oneSignalUserId == '' ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print(
          'Obtained OneSignal User ID: [36m${AppGlobals.oneSignalUserId}[0m');
      if (AppGlobals.oneSignalUserId.isEmpty) {
        //Get.snackbar('Enable Notifications',
        //    'Unable to get device ID. Please try again.');
        return;
      }
    }
    final data = {
      'event_id': AppGlobals.selEventId,
      'player_id': AppGlobals.oneSignalUserId,
      'number': athelete.id,
      'contest': athelete.contest
    };

    final res = await ApiHandler.postHttp(
        endPoint: '', baseUrl: entrantsList.follow!, body: data);
    if (res.statusCode == 201) {
      debugPrint('\u001b[32m$data---- Followed\u001b[0m');
    } else {
      debugPrint(res.data.toString());
    }
  }

  Future<void> unfollowAthlete(Entrants athelete) async {
    if (AppGlobals.oneSignalUserId == null ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print(
          'Obtained OneSignal User ID: [36m${AppGlobals.oneSignalUserId}[0m');
      if (AppGlobals.oneSignalUserId.isEmpty) {
        //Get.snackbar('Enable Notifications',
        //    'Unable to get device ID. Please try again.');
        return;
      }
    }
    final data = {
      'event_id': AppGlobals.selEventId,
      'player_id': AppGlobals.oneSignalUserId,
      'number': athelete.id,
      'contest': athelete.contest
    };
    final res = await ApiHandler.deleteHttp(
        endPoint: '', baseUrl: entrantsList.follow!, body: data);
    if (res.statusCode == 200) {
      debugPrint('\u001b[31m$data---- Unfollowed\u001b[0m');
    } else {
      debugPrint(res.data.toString());
    }
  }

  Future<void> followAthleteA(AppAthleteDb athelete) async {
    if (AppGlobals.oneSignalUserId == null ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print(
          'Obtained OneSignal User ID: [36m${AppGlobals.oneSignalUserId}[0m');
      if (AppGlobals.oneSignalUserId.isEmpty) {
        //Get.snackbar('Enable Notifications',
        //    'Unable to get device ID. Please try again.');
        return;
      }
    }

    final data = {
      'event_id': AppGlobals.selEventId,
      'player_id': AppGlobals.oneSignalUserId,
      'number': athelete.athleteId,
      'contest': athelete.contestNo
    };

    final res = await ApiHandler.postHttp(
        endPoint: '', baseUrl: entrantsList.follow!, body: data);
    if (res.statusCode == 201) {
      debugPrint('$data---- Followed');
    } else {
      debugPrint(res.data.toString());
    }
  }

  Future<void> unfollowAthleteA(AppAthleteDb athelete) async {
    if (AppGlobals.oneSignalUserId == null ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print(
          'Obtained OneSignal User ID: [36m${AppGlobals.oneSignalUserId}[0m');
      if (AppGlobals.oneSignalUserId.isEmpty) {
        //Get.snackbar('Enable Notifications',
        //    'Unable to get device ID. Please try again.');
        return;
      }
    }
    final data = {
      'event_id': AppGlobals.selEventId,
      'player_id': AppGlobals.oneSignalUserId,
      'number': athelete.athleteId,
      'contest': athelete.contestNo
    };
    final res = await ApiHandler.deleteHttp(
        endPoint: '', baseUrl: entrantsList.follow!, body: data);
    if (res.statusCode == 200) {
      debugPrint('$data---- Unfollowed');
    } else {
      debugPrint(res.data.toString());
    }
  }

  Future<void> insertAthlete(Entrants athlete, bool isFollowed) async {
    if (isFollowed) {
      await DatabaseHandler.insertAthlete(athlete);
    } else {
      await DatabaseHandler.removeAthlete(athlete.id);
    }
  }

  Future<void> insertAthleteA(AppAthleteDb athlete, bool isFollowed) async {
    var a = await DatabaseHandler.getSingleAthleteOnce(athlete.athleteId);
    if (a == null) {
      await DatabaseHandler.insertAthlete(Entrants(
        id: athlete.athleteId,
        disRaceNo: athlete.disRaceNo ?? '',
        number: athlete.athleteId,
        info: athlete.info,
        profileImage: athlete.profileImage,
        name: athlete.name,
        contest: athlete.contestNo,
        extra: athlete.extra,
        canFollow: athlete.canFollow,
        isFollowed: true,
      ));
    } else {
      print('here 2');
      await DatabaseHandler.removeAthlete(athlete.athleteId);
    }
  }

  Stream<List<AppAthleteDb>> watchAthletes(String val) async* {
    val = '';

    yield* DatabaseHandler.getAthletes(val, true);
    //
    //
    // // if(lastOffset == offset.value) {
    // //   controller.add(accumulatedList);
    // //   yield* controller.stream;
    // //   return;
    // // }
    // print('list.length 2');
    //
    // await for (final list in DatabaseHandler.getAthletes(val, true)) {
    //
    //   // Accumulate items into a list
    //   // Future.delayed(const Duration(milliseconds: 100), () {
    //   //   lastOffset = offset.value;
    //   // });
    //   print(list.length);
    //   print('list.length');
    //   for (final item in list) {
    //     int index = accumulatedList.indexWhere((element) => element.athleteId == item.athleteId);
    //     if(index == -1) {
    //       accumulatedList.add(item);
    //     } else {
    //       accumulatedList.removeAt(index);
    //       accumulatedList.insert(index, item);
    //     }
    //     // Yield a copy of the accumulated list
    //   }
    //   yield List.from(accumulatedList);
    // }
    //yield* DatabaseHandler.getAthletes(val, showFollowed.value, limit: limit, offset: offset.value);
  }

  Future<List<Entrants>> getAthletes(String val, {bool init = false}) async {
    if (init) {
      loading.value = true;
      searchAccumulatedList.clear();
      page = 1;
      lastPage = 1;
      searchText.value = '';
      searchTextEditController.clear();
    }
    loadingMore.value = true;
    update();

    List<AppAthleteDb> list = [];
    print('list.length 2');

    final entrantsList = AppGlobals.appConfig!.athletes!;

    var raceId = AppGlobals.selEventId;

    var data = await ApiHandler.postHttp(endPoint: 'athletes/$raceId', body: {
      'searchstring': searchText.value,
      'pagenumber': page,
      'include_country': true,
    });
    //var data = await ApiHandler.genericGetHttp(url: entrantsList.url!);

    print('API Response Data: ${data.data}');

    pagination = {
      "totalPages": data.data['pagination']['totalPages'],
      "currentPage": data.data['pagination']['currentPage'],
      "totalRecords": data.data['pagination']['totalRecords'],
    };

    for (final item in data.data['athletes']) {
      print('Athlete Item: $item');
      print('Country Field: ${item['country']}');
      var entrant = Entrants.fromJson(item);
      print('Parsed Entrant Country: ${entrant.country}');
      searchAccumulatedList.add(entrant);
    }
    lastPage = page;

    loading.value = false;
    loadingMore.value = false;
    update();
    return List.from(searchAccumulatedList);
  }

  void clearSearchField() {
    searchText.value = '';
    searchTextEditController.clear();
    offset.value = 0;
    page = 1;
    lastPage = 1;
    lastOffset = -1;
    accumulatedList = [];
    searchAccumulatedList = [];
    update();
    getAthletes('', init: true);
  }

  void toAthleteDetails(dynamic entrant, {Function(Entrants)? onFollow}) async {
    Get.focusScope?.unfocus();
    Get.toNamed(Routes.athleteDetails,
        arguments: {AppKeys.athlete: entrant, 'on_follow': onFollow});
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

  List<Entrants> sortFilterAthletesSearch(List<Entrants> athletes) {
    athletes.sort((x, y) {
      int xValue = _parseRaceno(x.disRaceNo);
      int yValue = _parseRaceno(y.disRaceNo);
      return xValue.compareTo(yValue);
    });

    List<Entrants> assignedRaceNoAthletes = [];
    List<Entrants> unAssignedRaceNoAthletes = [];

    // Put unassigned racenumber athletes to the end of list
    for (Entrants athlete in athletes) {
      if (athlete.id == '9999999') {
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
      return double.maxFinite
          .toInt(); // Assign a large value to non-integer raceno
    }
  }
}
