class AppEventConfig {
  AppEventConfig({
    required this.oneSignalId,
    this.splashImage,
    required this.appName,
    this.singleEventUrl,
    this.singleEventId,
    this.multiEventListUrl,
    this.multiEventListId,
  });

  final String appName;
  final String? splashImage;
  final String oneSignalId;
  final String? singleEventUrl;
  final String? singleEventId;
  final String? multiEventListUrl;
  final String? multiEventListId;
}
