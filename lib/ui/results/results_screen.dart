import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/results/results_screen_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/models/app_config.dart';
import '../../core/res/app_colors.dart';
import '../common_components/text.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ResultsScreenController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: AppText(
            controller.items!.title ?? '',
        ),
      ),
      body: GetBuilder(
        init: controller,
        builder: (_) {
          if(controller.loading.value) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          }
          return SingleChildScrollView(
            controller: controller.scrollController,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: .5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: DropdownButton<int>(items: [
                    ...controller.eventResponse?.data?.map((e) => DropdownMenuItem(value: e.eventId, child: Text(e.name))).toList() ?? [],
                  ], onChanged: (val) {
                    controller.changeEvent(val!);
                  }, icon: Icon(CupertinoIcons.chevron_down, color: Colors.grey), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), value: controller.selectedEvent.value, isExpanded: true, borderRadius: BorderRadius.circular(5), underline: Container()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ),
                        child: TextField(
                          style: TextStyle(
                            height: 1,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey, size: 22),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: .5,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: .5,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                          ),
                          onSubmitted: (val) {
                            controller.searchResults(val);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        controller.updateScrollController();
                        await showModalBottomSheet(context: context, elevation: 0, backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor, builder: (_) => BottomSheet(onClosing: () {
                          print('closing');
                        }, builder: (_) {
                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height*0.6,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 70,
                                              scrollController: FixedExtentScrollController(
                                                initialItem: (controller.eventResponse?.data?.where((element) => element.eventId == controller.selectedEvent.value).firstOrNull?.genders.where((element) => element.enabled).toList().where((element) => element.enabled).toList().indexWhere((element) => element.id == controller.gender) ?? -1)+1,
                                              )..addListener(() {
                                                print('scrolled');
                                              }),
                                              onSelectedItemChanged: (val) {
                                                controller.setGender(val);
                                              },
                                              children: [
                                                Center(
                                                  child: Text('All', style: TextStyle(
                                                    color: Colors.black,
                                                  ),),
                                                ),
                                                ...controller.eventResponse?.data?.where((element) => element.eventId == controller.selectedEvent.value).firstOrNull?.genders.where((element) => element.enabled).toList().map((e) => Container(
                                                  child: Center(
                                                    child: Text('${e.name}', style: TextStyle(
                                                      color: Colors.black,
                                                    ),),
                                                  ),
                                                )).toList() ?? [],
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: CupertinoPicker(
                                              itemExtent: 70,
                                            scrollController: controller.categoryScrollController,
                                              onSelectedItemChanged: (val) {
                                                controller.setCategory(val);
                                              },
                                              children: [
                                                Center(
                                                  child: Text('All', style: TextStyle(
                                                    color: Colors.black,
                                                  ),),
                                                ),
                                                ...controller.eventResponse?.data?.where((element) => element.eventId == controller.selectedEvent.value).firstOrNull?.categories.map((e) => Container(
                                                  child: Center(
                                                    child: Text('${e.name ?? e.code}', style: TextStyle(
                                                      color: Colors.black,
                                                    ),),
                                                  ),
                                                )).toList() ?? [],
                                              ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    bottom: MediaQuery.of(context).size.height*0.32,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).bottomSheetTheme.backgroundColor,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Row(
                                              children: [
                                                Expanded(child: Container(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Text('Gender', style: TextStyle(
                                                      fontSize: 16,
                                                    )))),
                                                Expanded(child: Container(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Text('Category', style: TextStyle(
                                                      fontSize: 16,
                                                    )))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CupertinoButton(
                                                  color: AppColors.primary,
                                                  onPressed: () {
                                                Navigator.of(context).pop();
                                              }, child: Text('APPLY', style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),)),
                                            ),
                                            const SizedBox(width: 16),
                                            CupertinoButton(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                color: Colors.grey[400],
                                                onPressed: () {
                                                  controller.setCategory(0);
                                                  controller.setGender(0);
                                                  Navigator.of(context).pop();
                                                }, child: Text('CLEAR', style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ))),
                                          ],
                                                                          ),
                                      ))
                                ],
                              ),
                            ),
                          );
                        }, elevation: 0,));
                        controller.filterResults();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 16,
                          left: 8,
                        ),
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: .5,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(child: Text('Filter', style: TextStyle(
                          fontSize: 16,
                        ),)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    var category = controller.eventResponse?.data?.where((element) => element.eventId == controller.selectedEvent.value).firstOrNull?.categories.where((element) => element.id == controller.category).firstOrNull;
                    var gender = controller.eventResponse?.data?.where((element) => element.eventId == controller.selectedEvent.value).firstOrNull?.genders.where((element) => element.enabled).toList().where((element) => element.id == controller.gender).firstOrNull;
                    return Row(
                      children: [
                        const SizedBox(width: 16),
                        Text('Gender ${gender?.name ?? gender?.code ?? 'All'} / Category ${category?.name ?? category?.code ?? 'All'}', style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Center(child: Text('Pos.', style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),)),
                      ),
                      Expanded(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Name.', style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),),
                      )),
                      Container(
                        width: 80,
                        child: Center(child: Text('Result', style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),)),
                      ),
                    ],
                  ),
                ),
                if(controller.loadingResults.value)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                ListView.builder(itemBuilder: (_, index) {

                  if(index == controller.eventResult!.data!.length) {
                    return Padding(padding: const EdgeInsets.all(16), child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ));
                  }

                  print('position');

                  var athlete = controller.eventResult!.data![index];

                  print('overallPos: ${athlete.overallPos}');
                  print('netOverallPos: ${athlete.netOverallPos}');
                  print('categoryPos: ${athlete.categoryPos}');
                  print('netCategoryPos: ${athlete.netCategoryPos}');
                  print('genderPos: ${athlete.genderPos}');
                  print('netGenderPos: ${athlete.netGenderPos}');

                  return GestureDetector(
                    onTap: () {
                      if(!(controller.items?.linkToDetail ?? false)) {
                        return;
                      }
                      AppAthleteDb athleteDb = AppAthleteDb(id: athlete.raceNo!, athleteId: athlete.raceNo!.toString(), canFollow: false, isFollowed: false, name: athlete.name??'Unknown', extra: '', profileImage: '', raceno: athlete.raceNo!.toString(), eventId: athlete.eventId!, info: '', contestNo: athlete.overallPos!, searchTag: '');
                      Get.toNamed(Routes.athleteDetails, arguments: {AppKeys.athlete: athleteDb, 'can_follow': false});
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text((index+1).toString()/*'${athlete.netOverallPos ?? athlete.overallPos}'*/),
                          ),
                          Expanded(child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${athlete.name}', style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${athlete.gender?.name} ${athlete.category?.name}', style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13,
                                ),),
                              ],
                            ),
                          )),
                          Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('${athlete.netTime ?? athlete.finishTime ?? athlete.finishStatus?.code}', textAlign: TextAlign.end,),
                          ),
                        ],
                      ),
                    ),
                  );
                }, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: (controller.eventResult?.data?.length ?? 0)+(controller.loadingMore.value ? 1 : 0))
              ],
            ),
          );
        }
      ),
    );
  }
}
