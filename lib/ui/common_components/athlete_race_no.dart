import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AthleteRaceNoStyle { outlined, solid, solidOutlined }

class AthleteRaceNo extends StatelessWidget {
  const AthleteRaceNo({
    super.key,
    this.width = 40,
    required this.number,
    this.athleteRaceNoStyle = AthleteRaceNoStyle.solidOutlined,
  });

  final double width;
  final int number;
  final AthleteRaceNoStyle athleteRaceNoStyle;

  Color backgroundColor() {
    switch (athleteRaceNoStyle) {
      case AthleteRaceNoStyle.outlined:
        return AppColors.transparent;
      case AthleteRaceNoStyle.solid:
      case AthleteRaceNoStyle.solidOutlined:
        return Theme.of(Get.context!).brightness == Brightness.light
            ? AppColors.grey
            : AppColors.greyLighter;
    }
  }

  BoxBorder? borderDecoration() {
    switch (athleteRaceNoStyle) {
      case AthleteRaceNoStyle.outlined:
      case AthleteRaceNoStyle.solidOutlined:
        return Border.all(color: AppColors.headerText.withOpacity(0.6));
      case AthleteRaceNoStyle.solid:
        return null;
    }
  }

  String raceNo() {
    if (number == -1) {
      return 'TBC';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      decoration: BoxDecoration(
          color: backgroundColor(),
          borderRadius: BorderRadius.circular(4),
          border: borderDecoration()),
      child: Center(
        child: AppText(
          raceNo(),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
          color:Theme.of(context).brightness == Brightness.light
                      ? AppColors.white
                      : AppColors.darkBlack,
          
        ),
      ),
    );
  }
}
