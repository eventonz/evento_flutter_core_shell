import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/evento_app.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/settings/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/res/app_styles.dart';
import '../common_components/text.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(LanguageController());

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        shadowColor: Colors.white,
        title: AppText(
          AppLocalizations.of(context)!.language,
          style: AppStyles.appBarTitle,
        ),
      ),
      body: ListView.builder(itemBuilder: (_, index) {
        return ListTile(
          onTap: () {
            controller.setLocale(controller.languages[index]['code']);
          },
          /*leading: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(AppHelper.getImage(controller.languages[index]['flag']), width: 36,)),*/
          title: Text(controller.languages[index]['name'], style: TextStyle(
            fontSize: 16.sp,
          ),),
          trailing: controller.locale!.value.languageCode == controller.languages[index]['code'] ? Icon(Icons.check) : null,
        );
      }, itemCount: controller.languages.length, padding: const EdgeInsets.symmetric(vertical: 10),),
    );
  }
}
