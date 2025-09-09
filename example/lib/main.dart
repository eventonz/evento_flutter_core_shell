import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';

void main() {
  // final eventConfig = AppEventConfig(
  //   oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
  //   appName: 'Single Event App',
  //   singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
  //   //configUrl: 'https://evento-nz.fra1.cdn.digitaloceanspaces.com/config/91.json',
  //   416
  //   splashImage: 'assets/images/splash_image.png',
  // );
   /*
  final eventConfig = AppEventConfig(
    oneSignalId: '111cddd2-0265-44d4-8aa2-af7982884d1b',
    appName: 'Pop Up Races',
    multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
    multiEventListId: '38',
    appId: 38,
    splashImage: 'assets/images/splash_image.png',
  );
*/
  final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Single Event App',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    //configUrl: 'https://evento-nz.fra1.cdn.digitaloceanspaces.com/config/91.json',
    singleEventId: '431',
    appId: 40,
    splashImage: 'assets/images/splash_image.png',
  );
  /*
 final eventConfig = AppEventConfig(
   oneSignalId: 'bd954eea-e5dc-4118-8c77-188b5fc1c33d',
    appName: 'My Results by SES',
    multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
    multiEventListId: '35',
    splashImage: 'assets/images/splash_image.png',
    searchbarcolor: const Color.fromRGBO(0, 0, 0, 0.5),
    
  );
*/

  runApp(EventoApp(
    appEventConfig: eventConfig,
  ));
}
