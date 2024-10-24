import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';

void main() {

 final eventConfig = AppEventConfig(
   oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
   appName: 'Single Event App',
   singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
   singleEventId: '172',
   splashImage: 'assets/images/splash_image.png',
 );

/*
final eventConfig = AppEventConfig(
    oneSignalId: '3138d661-ae18-4673-9218-de94842ab543',
    appName: 'The Race',
    multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
    multiEventListId: '23',
    splashImage: 'assets/images/splash_image.png',
  );

*/
  runApp(EventoApp(
    appEventConfig: eventConfig,
  ));
 }