import 'dart:io';
import 'dart:math';
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
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppHelper {
  static String getImage(String imageName) =>
      'packages/evento_core/assets/images/$imageName';

  static String getSvg(String imageName) =>
      'packages/evento_core/assets/svgs/$imageName.svg';

  static final Dio _dio = Dio();

  static String createUrl(String endPoint, String id) => '$endPoint/$id.json';

  static Color hexToColor(String? color) {
    if (color == null) {
      return AppColors.white;
    }
    return Color(int.parse(color.replaceAll('#', '0xFF')));
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

    int red = random.nextInt(128) + 140;
    int green = random.nextInt(128) + 140;
    int blue = random.nextInt(128) + 140;

    return Color.fromARGB(255, red, green, blue);
  }
}
