import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:evento_core/core/overlays/progress_dialog.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/ui/common_components/bottom_sheet.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class AppHelper {
  static String getImage(String imageName) =>
      'packages/evento_core/assets/images/$imageName';

  static Uint8List emptyImage = Uint8List.fromList([
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x60,
    0x60,
    0x60,
    0x00,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0xA5,
    0xF6,
    0x45,
    0x40,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82
  ]);

  static String getSvg(String imageName) =>
      'packages/evento_core/assets/svgs/$imageName.svg';

  static final Dio _dio = Dio();

  static String createUrl(String endPoint, String id) => '$endPoint/$id';

  static Color hexToColor(String? color) {
    if (color == null) {
      return AppColors.white;
    }
    return Color(int.parse(color.replaceAll('#', '0xFF')));
  }

  static double dgetBoundsZoomLevel(
    LatLngBounds bounds, {
    required double height,
    required double width,
  }) {
    var mapDim = {
      'height': height,
      'width': width,
    };

    var WORLD_DIM = {
      'height': height,
      'width': width,
    };

    double latRad(lat) {
      var sin2 = sin(lat * pi / 180);
      var radX2 = log((1 + sin2) / (1 - sin2)) / 2;
      return max(min(radX2, pi), -pi) / 2;
    }

    double zoom(mapPx, worldPx, fraction) {
      return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
    }

    var ne = bounds.northeast;
    var sw = bounds.southwest;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    double latZoom = zoom(mapDim['height'], WORLD_DIM['height'], latFraction);
    double lngZoom = zoom(mapDim['width'], WORLD_DIM['width'], lngFraction);

    return min(latZoom, lngZoom);
  }

  static Future<Uint8List> widgetToBytes(Widget widget,
      {int milliseconds = 100}) async {
    ScreenshotController screenshotController = ScreenshotController();
    var value = await screenshotController.captureFromWidget(widget,
        delay: Duration(milliseconds: milliseconds));
    return value;
    Codec codec = await instantiateImageCodec(value);
    FrameInfo fi = await codec.getNextFrame();
    var bytes = (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
    return bytes;
  }

  static void showDirectionsOnMap(LatLng? latLng) async {
    final lat = latLng?.latitude ?? 0;
    final lon = latLng?.longitude ?? 0;
    final appleUrl =
        'https://maps.apple.com/?saddr=&daddr=$lat,$lon&directionsmode=driving';
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    const errorMessage = 'Error, while trying to open the direction in map';

    if (Platform.isIOS) {
      final googleUrlRes =
          await AppHelper.launchUrlApp(googleUrl, showErrorMessage: false);
      if (!googleUrlRes) {
        await AppHelper.launchUrlApp(appleUrl, errorMessage: errorMessage);
      }
    } else {
      await AppHelper.launchUrlApp(googleUrl, errorMessage: errorMessage);
    }
  }

  static bool listsAreEqual(List list1, List list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  static Future<String> getWebTitle(String url) async {
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    final res = await _dio.get(url);
    String? title = RegExp(
            r"<[t|T]{1}[i|I]{1}[t|T]{1}[l|L]{1}[e|E]{1}(\s.*)?>([^<]*)</[t|T]{1}[i|I]{1}[t|T]{1}[l|L]{1}[e|E]{1}>")
        .stringMatch(res.data);
    if (title != null) {
      return title.substring(title.indexOf('>') + 1, title.lastIndexOf("<"));
    } else {
      return '';
    }
  }

  static Future<void> showWebBottomSheet(String? title, String url,
      [String? linkType]) async {
    String pageTitle = '';
    if (title == null) {
      try {
        ProgressDialogUtils.show();
        pageTitle = await getWebTitle(url);
        ProgressDialogUtils.dismiss();
      } catch (e) {
        ProgressDialogUtils.dismiss();
        debugPrint(e.toString());
        // ToastUtils.show('Something went wrong...');
        // return;
        pageTitle = '';
      }
    } else {
      pageTitle = title;
    }

    // if (Platform.isAndroid) {
    //   url = 'https://docs.google.com/gview?embedded=true&url=${url}';
    // }

    final wf.WebViewController webViewController = wf.WebViewController()
      ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(Get.context!).brightness == Brightness.light
          ? AppColors.white
          : AppColors.darkBlack)
      ..enableZoom(true)
      ..loadRequest(Uri.parse(url));

    await AppFixedBottomSheet(Get.context!).show(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    FeatherIcons.x,
                    color: Theme.of(Get.context!).brightness == Brightness.light
                        ? AppColors.accentLight
                        : AppColors.accentDark,
                  )),
              title: AppText(''),
              actions: [
                IconButton(
                  onPressed: () async {
                    try {
                      await Share.share(
                        url,
                        subject:
                            pageTitle.isNotEmpty ? pageTitle : 'Shared Link',
                      );
                    } catch (e) {
                      debugPrint('Error sharing: $e');
                      ToastUtils.show('Unable to share link');
                    }
                  },
                  icon: Icon(
                    FeatherIcons.share2,
                    color: Theme.of(Get.context!).brightness == Brightness.light
                        ? AppColors.accentLight
                        : AppColors.accentDark,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Platform.isAndroid && linkType == 'pdf'
                  ? ColoredBox(
                      color: AppColors.white, child: SfPdfViewer.network(url))
                  : wf.WebViewWidget(
                      controller: webViewController,
                    ),
            )
          ],
        ),
      ),
    );
  }

  static String setAthleteMenuText(String? val) {
    String finalVal = '';
    if (val == null || val.isEmpty) {
      finalVal = 'athletes';
    } else {
      final String lastVal = val.split('').last;
      if (lastVal == 's') {
        finalVal = val;
      } else {
        finalVal = '${val}s';
      }
    }
    return finalVal.capitalize!;
  }

  static Future<bool> launchUrlApp(String url,
      {String? errorMessage, bool showErrorMessage = true}) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      if (showErrorMessage) {
        ToastUtils.show(errorMessage ?? 'Something went wrong...');
      }
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  static ThemeMode getAppTheme(String themeMode) {
    for (ThemeMode value in ThemeMode.values) {
      if (value.toString().split('.').last == themeMode) {
        return value;
      }
    }
    throw ArgumentError('Invalid enum string: $themeMode');
  }

  static String notificationPrefenceKey(int eventId) {
    return '${eventId}_notification_status';
  }

  static Color getRandomLightColor() {
    Random random = Random();

    int red = random.nextInt(250) + 5;
    int green = random.nextInt(250) + 5;
    int blue = random.nextInt(250) + 5;

    return Color.fromARGB(255, red, green, blue);
  }

  static void showNotificationOptInPrompt({
    required BuildContext context,
    required int eventId,
    required void Function(bool allow) onResult,
  }) {
    final notificationSettingChanged = Preferences.getString(
        AppHelper.notificationPrefenceKey(eventId),
        NotificationStatus.initial.name);
    if (notificationSettingChanged == NotificationStatus.initial.name) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: AppText(
            AppLocalizations.of(context)!
                .wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: TextButton(
                      onPressed: () {
                        print('DEBUG: No Thanks button pressed');

                        // Dismiss the dialog first
                        Navigator.of(context, rootNavigator: true).pop();
                        print(
                            'DEBUG: Dialog dismissed with Navigator.pop(rootNavigator: true)');

                        // Set preference and call API in background
                        Preferences.setString(
                            AppHelper.notificationPrefenceKey(eventId),
                            NotificationStatus.hidden.name);
                        print('DEBUG: Preference set to hidden');

                        // Call the API in the background
                        onResult(false);
                        print('DEBUG: onResult called with false');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            AppColors.greyLight.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: AppText(
                        AppLocalizations.of(context)!.noThanks,
                        style: const TextStyle(
                          color: AppColors.darkgrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        print('🔔 NOTIFICATION PROMPT: User clicked YES');

                        // Dismiss the dialog first
                        print('🔔 NOTIFICATION PROMPT: Dismissing dialog');
                        Navigator.of(context, rootNavigator: true).pop();
                        print('🔔 NOTIFICATION PROMPT: Dialog dismissed');

                        // Request actual iOS permission
                        print(
                            '🔔 NOTIFICATION PROMPT: Requesting iOS notification permission with fallback: true');
                        try {
                          bool permissionGranted =
                              await OneSignal.Notifications.requestPermission(
                                  true);
                          print(
                              '🔔 NOTIFICATION PROMPT: iOS permission result: $permissionGranted');

                          // Wait a moment for OneSignal to process the permission
                          await Future.delayed(const Duration(seconds: 2));

                          // Check current permission status
                          var permissionStatus =
                              await OneSignal.Notifications.permission;
                          print(
                              '🔔 NOTIFICATION PROMPT: Current permission status: $permissionStatus');

                          // Try to get the push subscription ID now that permission is granted
                          String? pushId = OneSignal.User.pushSubscription.id;
                          print(
                              '🔔 NOTIFICATION PROMPT: Push subscription ID after permission: $pushId');

                          if (pushId != null && pushId.isNotEmpty) {
                            // Update the global user ID with the new push subscription ID
                            AppGlobals.oneSignalUserId = pushId;
                            await Preferences.setString(
                                AppKeys.oneSingleUserId, pushId);
                            print(
                                '🔔 NOTIFICATION PROMPT: Updated OneSignal user ID: $pushId');
                          }
                        } catch (e) {
                          print(
                              '🔔 NOTIFICATION PROMPT: Error requesting permission: $e');
                        }

                        // Set preference and call API in background
                        print(
                            '🔔 NOTIFICATION PROMPT: Setting preference to show for event: $eventId');
                        Preferences.setString(
                            AppHelper.notificationPrefenceKey(eventId),
                            NotificationStatus.show.name);
                        print(
                            '🔔 NOTIFICATION PROMPT: Preference set successfully');

                        // Call the API in the background
                        print('🔔 NOTIFICATION PROMPT: Calling onResult(true)');
                        onResult(true);
                        print('🔔 NOTIFICATION PROMPT: onResult completed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: const AppText(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.only(bottom: 16),
        ),
      );
    }
  }

  /// Updates the app theme to reflect new configuration colors
  /// This should be called after updating AppColors.primary and AppColors.secondary
  static void updateAppTheme() {
    try {
      // Force a theme rebuild by temporarily changing to a different theme mode
      // and then back to the current one to trigger a rebuild
      final currentThemeMode =
          Preferences.getString(AppKeys.appThemeStyle, ThemeMode.system.name);
      final newThemeMode = currentThemeMode == ThemeMode.light.name
          ? ThemeMode.dark
          : ThemeMode.light;

      // Change to different theme mode
      Get.changeThemeMode(newThemeMode);

      // Change back to original theme mode after a brief delay
      Future.delayed(const Duration(milliseconds: 50), () {
        final originalThemeMode = AppHelper.getAppTheme(currentThemeMode);
        Get.changeThemeMode(originalThemeMode);
      });
    } catch (e) {
      // If there's an error, just log it and continue
      debugPrint('Error updating app theme: $e');
    }
  }

  /// Gets a player ID on-demand with OneSignal as primary and device ID as fallback
  /// This should be called when following athletes instead of storing globally
  static Future<String> getPlayerId() async {
    try {
      // First try to get OneSignal User ID
      String? oneSignalId = OneSignal.User.pushSubscription.id;
      if (oneSignalId != null && oneSignalId.isNotEmpty) {
        // Store it for future use
        await Preferences.setString(AppKeys.oneSingleUserId, oneSignalId);
        AppGlobals.oneSignalUserId = oneSignalId;
        return oneSignalId;
      }

      // Check if we have a stored OneSignal ID
      String storedId = Preferences.getString(AppKeys.oneSingleUserId, '');
      if (storedId.isNotEmpty) {
        AppGlobals.oneSignalUserId = storedId;
        return storedId;
      }

      // Fallback: Generate a unique device-based ID
      String deviceId = await _generateDeviceId();

      // Store the fallback ID
      await Preferences.setString(AppKeys.oneSingleUserId, deviceId);
      AppGlobals.oneSignalUserId = deviceId;
      return deviceId;
    } catch (e) {
      debugPrint('Error getting player ID: $e');
      // Final fallback: Generate a random ID
      String randomId = _generateRandomId();
      await Preferences.setString(AppKeys.oneSingleUserId, randomId);
      AppGlobals.oneSignalUserId = randomId;
      return randomId;
    }
  }

  /// Generates a unique device ID using platform-specific information
  static Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      }

      // Hash the device ID for privacy (same method as in evento_app.dart)
      if (deviceId.isNotEmpty) {
        return _hashDeviceId(deviceId);
      }

      // If device ID is empty, generate from other device info
      return _hashDeviceId(
          '${deviceInfo.toString()}_${DateTime.now().millisecondsSinceEpoch}');
    } catch (e) {
      debugPrint('Error generating device ID: $e');
      return _hashDeviceId('fallback_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  /// Simple hash function for device ID privacy (same as in evento_app.dart)
  static String _hashDeviceId(String deviceId) {
    int hash = 0;
    for (int i = 0; i < deviceId.length; i++) {
      int char = deviceId.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.abs().toString();
  }

  /// Generates a random ID as final fallback
  static String _generateRandomId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(999999);
    return 'fallback_${timestamp}_$randomNum';
  }
}
