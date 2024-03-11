import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  try {
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  } catch(e) {
    print("Failed to initialize Firebase: $e");
  }


    final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Single Event App',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    singleEventId: '105',
    multiEventListId: null,
    splashImage: 'assets/images/splash_image.png',
  );

  // for running multi event app

    /*final eventConfig = AppEventConfig(
   oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
   appName: 'Multi Event App',
   multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
  multiEventListId: '2',
    splashImage: 'assets/images/splash_image.png',
  );*/


  // for running single event app
  /*
  final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Single Event App',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    singleEventId: '91',
    splashImage: 'assets/images/splash_image.png',
  );

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
