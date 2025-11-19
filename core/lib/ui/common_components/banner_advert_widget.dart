import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/advert.dart';
import 'package:evento_core/core/res/app_theme.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable banner advert widget that displays random banner adverts from the app config.
///
/// This widget automatically:
/// - Selects a random banner advert from the available banner adverts
/// - Handles click tracking and URL launching
/// - Shows/hides based on advert frequency settings
/// - Provides customizable styling options
///
/// Usage examples:
///
/// ```dart
/// // Simple usage - just shows the banner if available
/// BannerAdvertWidget()
///
/// // With custom title and padding
/// BannerAdvertWidget(
///   showTitle: true,
///   title: "Sponsored Content",
///   padding: EdgeInsets.all(16),
/// )
///
/// // With callbacks
/// BannerAdvertWidget(
///   onBannerTap: () => print('Banner tapped'),
///   onNoBannerAvailable: () => print('No banners to show'),
/// )
/// ```

class BannerAdvertWidget extends StatelessWidget {
  final bool showTitle;
  final String? title;
  final EdgeInsets? padding;
  final VoidCallback? onBannerTap;
  final VoidCallback? onNoBannerAvailable;

  const BannerAdvertWidget({
    Key? key,
    this.showTitle = false,
    this.title,
    this.padding,
    this.onBannerTap,
    this.onNoBannerAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final advert = _getRandomBannerAdvert();

    if (advert == null) {
      onNoBannerAvailable?.call();
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppThemeStyles.cardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle && title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: AppText(
                  title!,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  _trackEvent('click', advert);
                  onBannerTap?.call();
                  launchUrl(Uri.parse(advert.openUrl!));
                },
                child: Image(
                  image: CachedNetworkImageProvider(advert.image!),
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets a random banner advert from the available adverts list
  Advert? _getRandomBannerAdvert() {
    final advertList = AppGlobals.appConfig?.adverts ?? [];
    final bannerAdverts = advertList
        .where((element) => element.type == AdvertType.banner)
        .toList();

    if (bannerAdverts.isEmpty) {
      return null;
    }

    // If there's only one banner, return it
    if (bannerAdverts.length == 1) {
      return bannerAdverts.first;
    }

    // Get a random banner from the list
    final random = Random();
    final randomIndex = random.nextInt(bannerAdverts.length);
    return bannerAdverts[randomIndex];
  }

  /// Tracks advert events (impression, click)
  Future<void> _trackEvent(String action, Advert advert) async {
    try {
      String url = 'adverts/${advert.id}';
      await ApiHandler.postHttp(endPoint: url, body: {
        'action': action,
      });
    } catch (e) {
      print('Error tracking advert event: $e');
    }
  }
}

/// Banner Advert Controller for managing banner display logic
class BannerAdvertController extends GetxController {
  final RxBool showAdvert = false.obs;
  final RxList<Advert> advertList = <Advert>[].obs;

  /// Checks if banner should be shown based on frequency settings
  void checkAdvert({bool impression = true}) {
    advertList.value = AppGlobals.appConfig?.adverts ?? [];

    final bannerAdverts = advertList
        .where((element) => element.type == AdvertType.banner)
        .toList();

    if (bannerAdverts.isEmpty) {
      showAdvert.value = false;
      return;
    }

    // For now, we'll show banner for everyopen frequency
    // You can extend this logic for daily frequency if needed
    final shouldShowBanner = bannerAdverts.any((advert) =>
        advert.frequency == AdvertFrequency.everyOpen ||
        _shouldShowDailyBanner(advert));

    if (shouldShowBanner) {
      showAdvert.value = true;
      if (impression) {
        _trackEvent('impression', bannerAdverts.first);
      }
    } else {
      showAdvert.value = false;
    }
  }

  /// Checks if daily banner should be shown
  bool _shouldShowDailyBanner(Advert advert) {
    if (advert.frequency != AdvertFrequency.daily) {
      return true;
    }

    String lastOpen =
        Preferences.getString('last_banner_open_${advert.id}', '');
    if (lastOpen.isEmpty) {
      Preferences.setString(
          'last_banner_open_${advert.id}', DateTime.now().toString());
      return true;
    }

    DateTime dateTime = DateTime.parse(lastOpen);
    bool shouldShow = dateTime.day != DateTime.now().day;

    if (shouldShow) {
      Preferences.setString(
          'last_banner_open_${advert.id}', DateTime.now().toString());
    }

    return shouldShow;
  }

  /// Tracks advert events
  Future<void> _trackEvent(String action, Advert advert) async {
    try {
      String url = 'adverts/${advert.id}';
      await ApiHandler.postHttp(endPoint: url, body: {
        'action': action,
      });
    } catch (e) {
      print('Error tracking advert event: $e');
    }
  }

  /// Gets a random banner advert
  Advert? getRandomBannerAdvert() {
    final bannerAdverts = advertList
        .where((element) => element.type == AdvertType.banner)
        .toList();

    if (bannerAdverts.isEmpty) {
      return null;
    }

    if (bannerAdverts.length == 1) {
      return bannerAdverts.first;
    }

    final random = Random();
    final randomIndex = random.nextInt(bannerAdverts.length);
    return bannerAdverts[randomIndex];
  }
}
