import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'one_signal.dart';
import 'preferences.dart';

class AppGlobals {
  static AppGlobals? instance;
  static late AppEventConfig appEventConfig;
  static EventM? eventM;
  static late int selEventId;
  static AppConfig? appConfig;
  static late String appVersion;
  static late String oneSignalUserId;

  AppGlobals._internal() {
    instance = this;
  }

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Preferences.init();
    await ApiHandler.init();
    await Firebase.initializeApp();
    await AppOneSignal.init();
    DatabaseHandler.init();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    appVersion = await _getAppFullVersion();
  }

  static Future<void> checkOnUserId() async {
    oneSignalUserId = Preferences.getString(AppKeys.oneSingleUserId, '');
    if (oneSignalUserId.isEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        oneSignalUserId = await AppOneSignal.setOneSignalUserId();
        Preferences.setString(AppKeys.oneSingleUserId, oneSignalUserId);
      });
    }
  }

  static Future<String> _getAppFullVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    return version;
  }
}
