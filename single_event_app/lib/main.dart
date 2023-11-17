import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/evento_app.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() {
  final eventConfig = AppEventConfig(
    oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
    appName: 'Evento Demo',
    singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
    singleEventId: '91',
    splashImage: 'assets/images/splash_image.png',
  );

  runApp(EventoApp(
    appEventConfig: eventConfig,
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(child: Text('Hello world')),
      ),
    );
  }
}
