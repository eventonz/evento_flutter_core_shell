import 'package:evento_core/core/models/ss_event_response.dart';
import 'package:evento_core/core/models/ss_event_result.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../../core/models/app_config.dart';

class ResultsScreenController extends GetxController {

  late int raceId;

  SSEventResponse? eventResponse;
  SSEventResult? eventResult;
  RxInt selectedEvent = 0.obs;

  RxBool loading = true.obs;
  RxBool loadingResults = true.obs;
  RxBool loadingMore = false.obs;

  String search = '';
  int page = 1;

  Items? items;

  int category = -1;
  int gender = -1;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    items = (Get.arguments[AppKeys.moreItem] as Items);
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
    } else {
      gender = eventResponse?.data?.where((element) => element.eventId == selectedEvent.value).firstOrNull?.genders[index-1].id ?? 0;
    }
  }

  searchResults(String search) async {
    this.search = search;
    page = 1;
    loadingResults.value = true;
    update();
    getResults();
  }
  
  getEvent() async {
    var result = await ApiHandler.genericGetHttp(url: 'https://api.sportsplits.com/v2/races/$raceId/events/', header: {
      'X-API-KEY' : 'BGE7FS8EY98DFAT57K7XL527F6CA58CJ',
    });

    eventResponse = SSEventResponse.fromJson(result.data);
    selectedEvent.value = eventResponse?.data?.firstOrNull?.eventId ?? 0;
    loading.value = false;

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