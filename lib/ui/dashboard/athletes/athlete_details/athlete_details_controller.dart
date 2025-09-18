import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/models/athlete_tab_details.dart';
import 'package:evento_core/core/models/split_data.dart';
import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/models/detail_item.dart';

class AthleteDetailsController extends GetxController
    with GetTickerProviderStateMixin {
  AppAthleteDb? selEntrant;
  Entrants? selEntrantA;
  late String athleteSplitUrl = '';
  final athleteSplitDataSnap = DataSnapShot.loading.obs;
  AthleteTabDetailM? athleteTabDetailM;
  SplitDataM? splitData;
  late Athletes entrantsList;
  late TabController tabController;
  final showEnglargedImage = false.obs;
  final List<Tab> detailsTabs = [];
  final List<String> tabTitles = [];
  List<DetailItem> items = [];
  bool version2 = false;
  late int selectedTabIndex = 0;

  RxBool loading = false.obs;
  bool canFollow = true;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    print('AthleteDetailsController onInit - arguments: $res');
    entrantsList = AppGlobals.appConfig!.athletes!;
    if (res[AppKeys.athlete] is AppAthleteDb) {
      print('Found AppAthleteDb in arguments');
      selEntrant = res[AppKeys.athlete];
    } else if (res['id'] != null) {
      print('Found id in arguments: ${res['id']}');
      loading.value = true;
    } else {
      print('Found selEntrantA in arguments');
      selEntrantA = res[AppKeys.athlete];
    }
    canFollow = res['can_follow'] ?? true;
  }

  @override
  void onReady() {
    super.onReady();
    if (Get.arguments[AppKeys.athlete] != null) {
      print('Calling getSplitDetails()');
      getSplitDetails();
    } else {
      print('Calling getAthlete() with id: ${Get.arguments['id']}');
      getAthlete(Get.arguments['id'].toString());
    }
  }

  Future<void> getAthlete(String id) async {
    print('getAthlete called with id: $id');
    loading.value = true;
    update();

    var raceId = AppGlobals.selEventId;
    print('Current event ID: $raceId');

    var data = await ApiHandler.postHttp(
        endPoint: 'athletes/$raceId',
        body: {
          'searchstring': id,
          'athlete_id': id,
          'pagenumber': 1,
        },
        timeout: 15);

    print('API response: ${data.data}');

    if (data.data['athletes'].isNotEmpty) {
      print('Found ${data.data['athletes'].length} athletes');
      selEntrantA = Entrants.fromJson(data.data['athletes'][0]);
      print('Selected athlete: ${selEntrantA?.name}');
    } else {
      print('No athletes found in API response');
    }
    loading.value = false;
    update();
    getSplitDetails();
  }

  Future<void> getSplitDetails() async {
    if (athleteSplitUrl.isEmpty) {
      athleteSplitUrl = AppGlobals.appConfig!.athleteDetails!.url!;
    }
    String mainUrl = athleteSplitUrl.split('?').first;
    if (selEntrant == null) {
      mainUrl =
          '$mainUrl?bib=${selEntrantA!.number}&id=${selEntrantA!.id}&contest=${selEntrantA!.contest}';
    } else {
      mainUrl =
          '$mainUrl?bib=${selEntrant!.raceno}&id=${selEntrant!.athleteId}&contest=${selEntrant!.contestNo}';
    }

    athleteSplitDataSnap.value = DataSnapShot.loading;
    try {
      print(mainUrl);
      final res = await ApiHandler.genericGetHttp(url: mainUrl);
      if (res.statusCode == 200) {
        detailsTabs.clear();

        //Version 2

        if (res.data['version2'] != null) {
          items = (res.data['version2']['items'] as List)
              .map((e) => DetailItem.fromJson(e))
              .toList();
          version2 = true;
        }

        //Version 2

        if (res.data['tabs'] != null) {
          athleteTabDetailM = AthleteTabDetailM.fromJson(res.data);
          tabTitles.clear();
          for (String tabLabel in athleteTabDetailM!.order) {
            detailsTabs.add(Tab(icon: getTabIcon(tabLabel)));
            tabTitles.add(tabLabel);
          }
        } else {
          splitData = SplitDataM.fromJson(res.data);
          detailsTabs.add(Tab(icon: getTabIcon('summary')));
          detailsTabs.add(Tab(icon: getTabIcon('splits')));
        }
        tabController = TabController(length: detailsTabs.length, vsync: this);
        tabController.addListener(() {
          selectedTabIndex = tabController.index;
        });
        athleteSplitDataSnap.value = DataSnapShot.loaded;
      } else {
        athleteSplitDataSnap.value = DataSnapShot.error;
      }
      update();
    } catch (e) {
      debugPrint(e.toString());
      athleteSplitDataSnap.value = DataSnapShot.error;
    }
  }

  Stream<AppAthleteDb> getSingleAthlete(String athleteId) async* {
    yield* DatabaseHandler.getSingleAthlete(athleteId);
  }

  Stream<List<AppAthleteExtraDetailsDb>> getSingleAthleteDetails(
      String athleteId) async* {
    yield* DatabaseHandler.getSingleAthleteDetails(athleteId);
  }

  Future<void> updateAthlete(AppAthleteDb athelete, bool isFollowed) async {
    isFollowed = !isFollowed;
    await DatabaseHandler.updateAthlete(athelete, isFollowed);
    if (isFollowed) {
      followAthlete(athelete);
    } else {
      unfollowAthlete(athelete);
    }
  }

  Future<void> followAthlete(AppAthleteDb athelete) async {
    if (AppGlobals.oneSignalUserId == null ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print('Obtained OneSignal User ID: ${AppGlobals.oneSignalUserId}');
      if (AppGlobals.oneSignalUserId.isEmpty) {
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

  Future<void> unfollowAthlete(AppAthleteDb athelete) async {
    if (AppGlobals.oneSignalUserId == null ||
        AppGlobals.oneSignalUserId.isEmpty) {
      String? userId = OneSignal.User.pushSubscription.id;
      AppGlobals.oneSignalUserId = userId ?? '';
      print('Obtained OneSignal User ID: ${AppGlobals.oneSignalUserId}');
      if (AppGlobals.oneSignalUserId.isEmpty) {
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

  void toggleEnlargedImage() {
    showEnglargedImage.value = !showEnglargedImage.value;
  }

  Widget getTabIcon(String tabLabel) {
    switch (tabLabel) {
      case 'summary':
        return const Icon(Icons.emoji_events_outlined);
      case 'splits':
        return const Icon(FeatherIcons.clock);
      default:
        return const Icon(FeatherIcons.columns);
    }
  }
}
