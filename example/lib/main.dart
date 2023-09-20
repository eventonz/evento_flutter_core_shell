import 'dart:async';
import 'package:evento_core/evento_app.dart';
import 'package:evento_multievent/app_event_selector.dart';
import 'package:evento_multievent/flavors.dart';
import 'package:flutter/material.dart';

FutureOr<void> main() async {
  runApp(
    EventoApp(
      appEventConfig: AppEventSelector.getEventInfo(F.appFlavor!),
    ),
  );
}
