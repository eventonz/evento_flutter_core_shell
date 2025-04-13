import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/models/athlete_tab_details.dart';
import 'package:evento_core/core/models/split_data.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

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

  bool canFollow = true;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    entrantsList = AppGlobals.appConfig!.athletes!;
    if(res[AppKeys.athlete] is AppAthleteDb) {
      selEntrant = res[AppKeys.athlete];
    } else {
      selEntrantA = res[AppKeys.athlete];
    }
    canFollow = res['can_follow'] ?? true;
  }

  @override
  void onReady() {
    super.onReady();
    getSplitDetails();
  }

  Future<void> getSplitDetails() async {
    if (athleteSplitUrl.isEmpty) {
      athleteSplitUrl = AppGlobals.appConfig!.athleteDetails!.url!;
    }
    String mainUrl = athleteSplitUrl.split('?').first;
    mainUrl = 'https://eventotracker.com/api/v3/api.cfm/splits/race/91';
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
