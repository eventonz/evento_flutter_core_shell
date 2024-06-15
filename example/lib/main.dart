import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';

void main() {
    /*final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Single Event App',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    singleEventId: '96',
    multiEventListId: null,
    splashImage: 'assets/images/splash_image.png',
  );*/

  // for running multi event app
  final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Single Event App',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    singleEventId: '91',
    splashImage: 'assets/images/splash_image.png',
  );

  /*final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Multi Event App',
    multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
    multiEventListId: '2',
    splashImage: 'assets/images/splash_image.png',
  );*/


  /*
    final eventConfig = AppEventConfig(
   oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
   appName: 'Multi Event App',
   multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
  multiEventListId: '2',
    splashImage: 'assets/images/splash_image.png',
  );


  // for running single event app



  for running multi event app
    final eventConfig = AppEventConfig(
   oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
   appName: 'Multi Event App',
   multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
  multiEventListId: '13',
    splashImage: 'assets/images/splash_image.png',
  );
*/
  runApp(EventoApp(
    appEventConfig: eventConfig,
  ));
}
