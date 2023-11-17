import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/initial_binding.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/routes/router.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventoApp extends StatelessWidget {
  const EventoApp({super.key, required this.appEventConfig});
  final AppEventConfig appEventConfig;

  @override
  Widget build(BuildContext context) {
    AppGlobals.appEventConfig = appEventConfig;
    return LayoutBuilder(
      builder: (_, constraints) {
        return OrientationBuilder(
          builder: (_, orientation) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppStyles.light,
              darkTheme: AppStyles.dark,
              initialRoute: Routes.landing,
              getPages: PageRouter.pages,
              initialBinding: MainBinding(),
              builder: (_, child) {
                return ResponsiveSizer(
                    builder: (context, orientation, screenSize) =>
                        child ?? const SizedBox.shrink());
              },
            );
          },
        );
      },
    );
  }
}
