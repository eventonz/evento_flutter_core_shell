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

import '../../core/models/app_config.dart';

class ResultsScreenController extends GetxController {

  late int raceId;

  SSEventResponse? eventResponse;
  SSEventResult? eventResult;
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

  @override
  void onInit() {
    super.onInit();

    items = (Get.arguments?[AppKeys.moreItem] as Items?);
    items ??= AppGlobals.appConfig?.results?.config;

    print(items?.toJson());

    raceId = items!.sportSplitsRaceId ?? 0;
    getEvent();
    scrollController.addListener(() {
      print(scrollController.position.maxScrollExtent);
      print(scrollController.offset);
      if(scrollController.position.maxScrollExtent-scrollController.offset <=200 && !loadingMore.value) {
        print('scrolled');
        loadingMore.value = true;
        page++;
        update();
        getResults();
      }
    });
  }

  setCategory(int index) {
    if(index == 0) {
      category = -1;
    } else {
      category = eventResponse?.data?.where((element) => element.eventId == selectedEvent.value).firstOrNull?.categories[index-1].id ?? 0;
    }
  }

  setGender(int index) {
    if(index == 0) {
      gender = -1;
      category = -1;
      attached = false;
      categoryScrollController?.jumpTo(0);
      attached = true;
    } else {
      gender = eventResponse?.data?.where((element) => element.eventId == selectedEvent.value).firstOrNull?.genders.where((element) => element.enabled).toList()[index-1].id ?? 0;
    }
  }

  categoryListener() {
    if(gender == -1 && attached) {
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
      initialItem: (eventResponse?.data?.where((element) => element.eventId == selectedEvent.value).firstOrNull?.categories.indexWhere((element) => element.id == category) ?? -1)+1,
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
    var result = await ApiHandler.genericGetHttp(url: 'https://api.sportsplits.com/v2/races/$raceId/events/', header: {
      'X-API-KEY' : 'BGE7FS8EY98DFAT57K7XL527F6CA58CJ',
    });

    eventResponse = SSEventResponse.fromJson(result.data);
    if(first) {
      selectedEvent.value = eventResponse?.data?.firstOrNull?.eventId ?? 0;
    }
    loading.value = false;

    categoryScrollController = FixedExtentScrollController(
      initialItem: (eventResponse?.data?.where((element) => element.eventId == selectedEvent.value).firstOrNull?.categories.indexWhere((element) => element.id == category) ?? -1)+1,
    )..addListener(categoryListener);

    getResults();

    ((result.data as Map)['data'] as List).first.keys.forEach((element) {
      print('key: $element');
      print(((result.data as Map)['data'] as List).first[element]);
    });

    update();

    print(result.data);
  }

  filterResults() async {
    loadingResults.value = true;
    page = 1;
    update();
    getResults();
  }

  getResults() async {
    var url = 'https://api.sportsplits.com/v2/races/$raceId/events/${selectedEvent.value}/results/${category == -1 && gender == -1 ? 'individuals' : (category != -1 && gender != -1 ? 'gender/$gender/category/$category' : (category != -1 ? 'category/$category' : ('gender/$gender')))}?page=$page${search != '' ? '&search=$search' : ''}';

    if(search != '') {
      url = 'https://api.sportsplits.com/v2/races/$raceId/results/individuals?search=$search';
    }
    print(url);
    if(category != -1) {
      url += '';
    }
    var result = await ApiHandler.genericGetHttp(url: url, header: {
      'X-API-KEY' : 'BGE7FS8EY98DFAT57K7XL527F6CA58CJ',
    });

    var eventResult = SSEventResult.fromJson(result.data);
    loadingResults.value = false;
    loadingMore.value = false;

    print(result.data);

    if(page == 1) {
      this.eventResult = eventResult;
    } else {
      this.eventResult!.data!.addAll(eventResult.data!);
    }
    update();

  }

}