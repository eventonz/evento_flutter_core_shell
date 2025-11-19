import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';
import 'app_config.g.dart';

void main() {
  final eventConfig = AppEventConfig(
    oneSignalId: appConfig.oneSignalId,
    appName: appConfig.appName,
    singleEventUrl: appConfig.singleEventUrl,
    singleEventId: appConfig.singleEventId,
    multiEventListUrl: appConfig.multiEventListUrl,
    multiEventListId: appConfig.multiEventListId,
    appId: appConfig.appId,
    splashImage: appConfig.splashImage,
    searchbarcolor: appConfig.searchbarcolor,
    isTimer: appConfig.isTimer,
  );

  runApp(EventoApp(appEventConfig: eventConfig));
}
