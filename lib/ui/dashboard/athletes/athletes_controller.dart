import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AthletesController extends GetxController {
  late String athleteText;
  final TextEditingController searchTextEditController =
      TextEditingController();
  final searchText = ''.obs;
  late Athletes entrantsList;
  final showFollowed = false.obs;
  final DashboardController dashboardController = Get.find();

  @override
  void onInit() {
    super.onInit();
    entrantsList = AppGlobals.appConfig!.athletes!;
    athleteText = AppHelper.setAthleteMenuText(entrantsList.text);
  }

  void toggleFollowed() {
    showFollowed.value = !showFollowed.value;
    update();
  }

  Future<void> searchAthletes(String val) async {
    searchText.value = val;
    update();
  }

  Stream<List<AppAthleteDb>> watchAthletes(String val) async* {
    yield* DatabaseHandler.getAthletes(val, showFollowed.value);
  }

  void clearSearchField() {
    searchText.value = '';
    searchTextEditController.clear();
    update();
  }

  void toAthleteDetails(AppAthleteDb entrant) async {
    Get.focusScope?.unfocus();
    Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: entrant});
  }

  List<AppAthleteDb> sortFilterAthletes(List<AppAthleteDb> athletes) {
    athletes.sort((x, y) => x.raceno.compareTo(y.raceno));
    List<AppAthleteDb> assignedRaceNoAthletes = [];
    List<AppAthleteDb> unAssignedRaceNoAthletes = [];

    for (AppAthleteDb athlete in athletes) {
      if (athlete.raceno == -1) {
        unAssignedRaceNoAthletes.add(athlete);
      } else {
        assignedRaceNoAthletes.add(athlete);
      }
    }

    return [...assignedRaceNoAthletes, ...unAssignedRaceNoAthletes];
  }
}
