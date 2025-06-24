import 'package:evento_core/core/models/ss_event_response.dart';
import 'package:evento_core/core/models/ss_event_result.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'dart:async';

import '../../core/models/app_config.dart';
import '../../core/models/ss_leaderboard_result.dart';

class LeaderboardScreenController extends GetxController {
  late int raceId;

  SSEventResponse? eventResponse;
  AthleteLeaderboardResponse? eventResult;
  RxInt selectedEvent = 0.obs;

  FixedExtentScrollController? categoryScrollController;

  RxBool loading = true.obs;
  RxBool loadingResults = true.obs;
  RxBool loadingMore = false.obs;

  String search = '';
  int page = 1;

  Items? items;

  int category = -1;
  int gender = -1;

  bool attached = true;

  final ScrollController scrollController = ScrollController();

  Timer? _refreshTimer;
  RxBool isRefreshed = false.obs;

  @override
  void onInit() {
    super.onInit();

    items = (Get.arguments?[AppKeys.moreItem] as Items?);
    items ??= AppGlobals.appConfig?.results?.config;

    raceId = items!.sportSplitsRaceId ?? 0;
    getEvent();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent - scrollController.offset <=
              200 &&
          !loadingMore.value) {
        loadingMore.value = true;
        page++;
        update();
        getResults();
      }
    });
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      await filterResults(showLoading: false);
      _showRefreshIndicator();
    });
  }

  void _showRefreshIndicator() {
    isRefreshed.value = true;
    Future.delayed(Duration(seconds: 1), () {
      isRefreshed.value = false;
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  setCategory(int index) {
    if (index == 0) {
      category = -1;
    } else {
      category = eventResponse?.data
              ?.where((element) => element.eventId == selectedEvent.value)
              .firstOrNull
              ?.categories[index - 1]
              .id ??
          0;
    }
  }

  setGender(int index) {
    if (index == 0) {
      gender = -1;
      category = -1;
      attached = false;
      categoryScrollController?.jumpTo(0);
      attached = true;
    } else {
      gender = eventResponse?.data
              ?.where((element) => element.eventId == selectedEvent.value)
              .firstOrNull
              ?.genders
              .where((element) => element.enabled)
              .toList()[index - 1]
              .id ??
          0;
    }
  }

  categoryListener() {
    if (gender == -1 && attached) {
      categoryScrollController?.jumpTo(0);
      ToastUtils.show(AppLocalizations.of(Get.context!)!.selectGenderFirst);
      return;
    }
  }

  changeEvent(int id) async {
    selectedEvent.value = id;
    gender = -1;
    category = -1;
    loading.value = true;
    loadingResults.value = true;
    update();
    getEvent(false);
  }

  updateScrollController() {
    categoryScrollController = FixedExtentScrollController(
      initialItem: (eventResponse?.data
                  ?.where((element) => element.eventId == selectedEvent.value)
                  .firstOrNull
                  ?.categories
                  .indexWhere((element) => element.id == category) ??
              -1) +
          1,
    )..addListener(categoryListener);
  }

  searchResults(String search) async {
    this.search = search;
    page = 1;
    loadingResults.value = true;
    update();
    getResults();
  }

  getEvent([bool first = true]) async {
    try {
      var result = await ApiHandler.genericGetHttp(
          url: 'https://api.sportsplits.com/v2/races/$raceId/events/',
          header: {
            'X-API-KEY': 'BGE7FS8EY98DFAT57K7XL527F6CA58CJ',
          });

      eventResponse = SSEventResponse.fromJson(result.data);
      if (first) {
        selectedEvent.value = eventResponse?.data?.firstOrNull?.eventId ?? 0;
      }
      loading.value = false;

      categoryScrollController = FixedExtentScrollController(
        initialItem: (eventResponse?.data
                    ?.where((element) => element.eventId == selectedEvent.value)
                    .firstOrNull
                    ?.categories
                    .indexWhere((element) => element.id == category) ??
                -1) +
            1,
      )..addListener(categoryListener);

      getResults();

      ((result.data as Map)['data'] as List).first.keys.forEach((element) {
        print('key: $element');
        print(((result.data as Map)['data'] as List).first[element]);
      });

      update();
    } catch (e) {
      if (e.toString().contains('500')) {
        ToastUtils.show('A server error occurred. Please try again later.');
      }
      rethrow;
    }
  }

  filterResults({bool showLoading = true}) async {
    if (showLoading) {
      loadingResults.value = true;
    }
    page = 1;
    update();
    await getResults(showLoading: showLoading);
  }

  getResults({bool showLoading = true}) async {
    try {
      final apiGender = (gender == -1) ? 1 : gender;
      var url =
          'https://api.sportsplits.com/v2/races/$raceId/events/${selectedEvent.value}/leaderboards/leaderboard/results/${category == -1 && gender == -1 ? 'gender/$apiGender' : (category != -1 && gender != -1 ? 'gender/$apiGender/category/$category' : (category != -1 ? 'category/$category' : ('gender/$apiGender')))}/overall?page=$page${search != '' ? '&search=$search' : ''}';

      if (search != '') {
        url =
            'https://api.sportsplits.com/v2/races/$raceId/results/individuals?search=$search';
      }
      if (category != -1) {
        url += '';
      }
      var result = await ApiHandler.genericGetHttp(url: url, header: {
        'X-API-KEY': 'BGE7FS8EY98DFAT57K7XL527F6CA58CJ',
      });

      var eventResult = AthleteLeaderboardResponse.fromJson(result.data);
      if (showLoading) {
        loadingResults.value = false;
      }
      loadingMore.value = false;

      if (page == 1) {
        this.eventResult = eventResult;
      } else {
        this.eventResult!.data!.addAll(eventResult.data!);
      }
      update();
    } catch (e) {
      if (e.toString().contains('500')) {
        ToastUtils.show('A server error occurred. Please try again later.');
      }
      if (showLoading) {
        loadingResults.value = false;
      }
      rethrow;
    }
  }
}
