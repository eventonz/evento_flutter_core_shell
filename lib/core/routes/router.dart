import 'package:evento_core/ui/assistant/assistant.dart';
import 'package:evento_core/ui/dashboard/athletes/athlete_details/athlete_details.dart';
import 'package:evento_core/ui/dashboard/dashboard.dart';
import 'package:evento_core/ui/carousel/carousel.dart';
import 'package:evento_core/ui/dashboard/webview_event_page.dart';
import 'package:evento_core/ui/eventomap/eventomap.dart';
import 'package:evento_core/ui/list_page/list_page.dart';
import 'package:evento_core/ui/events/events.dart';
import 'package:evento_core/ui/landing/landing.dart';
import 'package:evento_core/ui/miniplayer/miniplayer_screen.dart';
import 'package:evento_core/ui/qr_scanner/qr_scanner.dart';
import 'package:evento_core/ui/results/results_screen.dart';
import 'package:evento_core/ui/schedule/schedule.dart';
import 'package:evento_core/ui/settings/settings.dart';
import 'package:evento_core/ui/user_challenge/challenge.dart';
import 'package:evento_core/ui/webview/webview.dart';
import 'package:get/get.dart';
import '../../ui/storyslider/story_slider_screen.dart';
import 'routes.dart';

class PageRouter {
  static final List<GetPage> pages = [
    GetPage(
      name: Routes.landing,
      page: () => const LandingScreen(),
    ),
    GetPage(
      name: Routes.events,
      page: () => const EventsScreen(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: Routes.webviewEvent,
      page: () => const WebViewEventPage(),
    ),
    GetPage(
      name: Routes.miniplayer,
      page: () => const MiniPlayerScreen(),
    ),
    GetPage(
      name: Routes.athleteDetails,
      page: () => AthleteDetailsScreen(),
    ),
    GetPage(
      name: Routes.webview,
      page: () => const WebviewScreen(),
    ),
    GetPage(
      name: Routes.eventResults,
      page: () => const ListPageScreen(),
    ),
    GetPage(
      name: Routes.eventoMap,
      page: () => const EventoMap(),
    ),
    GetPage(
      name: Routes.eventOffers,
      page: () => const EventOffersScreen(),
    ),
    GetPage(
      name: Routes.schedule,
      page: () => const ScheduleScreen(),
    ),
    GetPage(
      name: Routes.userChallenge,
      page: () => const ChallengeScreen(),
    ),
    GetPage(
      name: Routes.qrScanner,
      page: () => const QRScannerScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: Routes.assistant,
      page: () => const AssistantScreen(),
    ),
    GetPage(
      name: Routes.storySlider,
      page: () => const StorySliderScreen(),
    ),
    GetPage(
      name: Routes.results,
      page: () => const ResultsScreen(),
    ),
  ];
}
