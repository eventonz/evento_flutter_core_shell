import 'dart:ui';

class AppEventConfig {
  AppEventConfig({
    required this.oneSignalId,
    this.splashImage,
    this.configUrl,
    required this.appName,
    this.singleEventUrl,
    this.singleEventId,
    this.multiEventListUrl,
    this.multiEventListId,
    this.isTimer,
    this.searchbarcolor,
  });

  final String appName;
  final String? configUrl;
  final String? splashImage;
  final String oneSignalId;
  final String? singleEventUrl;
  final String? singleEventId;
  final String? multiEventListUrl;
  final String? multiEventListId;
  final bool? isTimer;
  final Color? searchbarcolor;
}
