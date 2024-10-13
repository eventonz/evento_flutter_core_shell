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
import 'package:evento_core/ui/common_components/bottom_sheet.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppHelper {
  static String getImage(String imageName) =>
      'packages/evento_core/assets/images/$imageName';

  static Uint8List emptyImage = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x60, 0x60, 0x60, 0x00,
    0x00, 0x00, 0x05, 0x00, 0x01, 0xA5, 0xF6, 0x45, 0x40, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
    0x44, 0xAE, 0x42, 0x60, 0x82
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

  static double dgetBoundsZoomLevel(LatLngBounds bounds, {
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
      return max(min(radX2, pi), - pi) / 2;
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

  static Future<Uint8List> widgetToBytes(Widget widget, {int milliseconds = 100}) async {
    ScreenshotController screenshotController = ScreenshotController();
    var value = await screenshotController.captureFromWidget(widget, delay: Duration(milliseconds: milliseconds));
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

  static Future<void> showWebBottomSheet(String? title, String url, [String? linkType]) async {
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

    final WebViewController webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
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
                        ? AppColors.accentDark
                        : AppColors.accentLight,
                  )),
              title: AppText(
                pageTitle.trim(),
              ),
            ),
            Expanded(
              child: Platform.isAndroid && linkType == 'pdf'
                  ? ColoredBox(
                      color: AppColors.white, child: SfPdfViewer.network(url))
                  : WebViewWidget(
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
}
