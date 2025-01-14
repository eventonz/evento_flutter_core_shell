import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';

void main() {

 final eventConfig = AppEventConfig(
   oneSignalId: '805fa94a-d7da-47a0-9885-5f7de965e1bd',
   appName: 'Single Event App',
   multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
   //configUrl: 'https://evento-nz.fra1.cdn.digitaloceanspaces.com/config/172.json',
   multiEventListId: '34',
   //singleEventId: '91',
   //singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
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