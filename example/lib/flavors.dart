enum Flavor {
  flavordemo,
  eventodemo,
  epicseries,
  motatapu,
  noosatri,
  mootri,
  uta,
  rtb,
  auckland,
  whaka100,
  ironman,
  runaway,
  challenge,
  coasttocoast,
  chmarathon,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.flavordemo:
        return 'Evento Tracker';
      case Flavor.eventodemo:
        return 'Evento Demo';
      case Flavor.epicseries:
        return 'Epic Series';
      case Flavor.motatapu:
        return 'Motatapu';
      case Flavor.noosatri:
        return 'Noosatri';
      case Flavor.mootri:
        return 'Mootri';
      case Flavor.uta:
        return 'UTA';
      case Flavor.rtb:
        return 'Round the Bays';
      case Flavor.auckland:
        return 'AA Marathon';
      case Flavor.whaka100:
        return 'Whaka 100';
      case Flavor.ironman:
        return 'IRONMAN';
      case Flavor.runaway:
        return 'Runaway';
      case Flavor.challenge:
        return 'Challenge Wanaka';
      case Flavor.coasttocoast:
        return 'Coast To Coast';
      case Flavor.chmarathon:
        return 'CH Marathon';
      default:
        return 'title';
    }
  }
}
