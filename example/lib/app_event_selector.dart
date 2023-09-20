import 'package:evento_core/app_event_config.dart';
import 'package:evento_multievent/flavors.dart';

class AppEventSelector {
  static Flavor? eventApp;

  static AppEventConfig getEventInfo(Flavor eventApp) {
    switch (eventApp) {
      case Flavor.flavordemo:
        return AppEventConfig(
          multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
          multiEventListId: '13',
          appName: eventApp.name,
          splashImage: 'assets/images/epicseries.png',
          oneSignalId: '75774a24-f051-4ba2-b21c-24673581fdec',
        );

      case Flavor.eventodemo:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '91',
          appName: eventApp.name,
          splashImage: 'assets/images/epicseries.png',
          oneSignalId: '31c166a5-3735-4ed7-8bea-b3de9b96a687',
        );

      case Flavor.epicseries:
        return AppEventConfig(
          multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
          multiEventListId: '2',
          appName: eventApp.name,
          splashImage: 'assets/images/epicseries.png',
          oneSignalId: 'e82dfebb-4f6e-4262-99d6-a185c42f1ab0',
        );

      case Flavor.motatapu:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '90',
          appName: eventApp.name,
          splashImage: 'assets/images/motatapu.png',
          oneSignalId: '00842052-a992-48b0-aad7-ede23179feea',
        );

      case Flavor.noosatri:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '92',
          appName: eventApp.name,
          splashImage: 'assets/images/noosatri.png',
          oneSignalId: 'd88e7667-24f2-464c-867a-c8fcc94d8456',
        );

      case Flavor.mootri:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '91',
          appName: eventApp.name,
          splashImage: 'assets/images/mootri.png',
          oneSignalId: '5b8367a9-b38c-4270-94d2-13a2ee246636',
        );

      case Flavor.uta:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '97',
          appName: eventApp.name,
          splashImage: 'assets/images/ultratrailaustralia.png',
          oneSignalId: '258ba43e-7781-4b74-8b1f-0baa4b5ae824',
        );

      case Flavor.rtb:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '77',
          appName: eventApp.name,
          splashImage: 'assets/images/rtb.png',
          oneSignalId: '2f12dbb7-0603-46ce-9e31-96b65c9308e5',
        );

      case Flavor.auckland:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '94',
          multiEventListUrl: '',
          multiEventListId: '',
          appName: eventApp.name,
          splashImage: 'assets/images/aamarathon.png',
          oneSignalId: '1bda2692-7758-4ceb-af3c-4b5d2c84c78e',
        );

      case Flavor.whaka100:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '64',
          appName: eventApp.name,
          splashImage: 'assets/images/whaka100.png',
          oneSignalId: '35fdfb31-1bbe-4ca7-9c45-fbac2f279769',
        );

      case Flavor.ironman:
        return AppEventConfig(
          multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
          multiEventListId: '13',
          appName: eventApp.name,
          splashImage: 'assets/images/ironmanoceania.png',
          oneSignalId: '2dc4fa23-2c3c-4812-b723-3b91df6df877',
        );

      case Flavor.runaway:
        return AppEventConfig(
          multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
          multiEventListId: '7',
          appName: eventApp.name,
          splashImage: 'assets/images/runaway.png',
          oneSignalId: '43b40306-afce-46e6-9085-79c46e21fda2',
        );

      case Flavor.challenge:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '116',
          multiEventListUrl: '',
          multiEventListId: '',
          appName: eventApp.name,
          splashImage: 'assets/images/cyclechallenge.png',
          oneSignalId: 'd19042a8-af05-46e6-a59b-8ad38d306dbf',
        );

      case Flavor.coasttocoast:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '78',
          appName: eventApp.name,
          splashImage: 'assets/images/challengewanaka.png',
          oneSignalId: '214158b0-07b1-4d52-8908-1b265d50f079',
        );

      case Flavor.chmarathon:
        return AppEventConfig(
          singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
          singleEventId: '114',
          appName: eventApp.name,
          splashImage: 'assets/images/chmarathon.png',
          oneSignalId: '0301a4c5-e321-487b-996a-b24a8e6dabfc',
        );
    }
  }
}
