class AthleteLeaderboardResponse {
  final int currentPage;
  final List<AthleteResult> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  AthleteLeaderboardResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory AthleteLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return AthleteLeaderboardResponse(
      currentPage: json['current_page'],
      data: List<AthleteResult>.from(
          json['data'].map((x) => AthleteResult.fromJson(x))),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: List<PageLink>.from(json['links'].map((x) => PageLink.fromJson(x))),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class AthleteResult {
  final int athleteId;
  final String eventId;
  final dynamic alphaRaceNo;
  final int bib;
  final String firstName;
  final Gender gender;
  final String lastName;
  final int raceNo;
  final Country countryRepresenting;
  final String importKey;
  final String leaderboardId;
  final Category category;
  final int splitId;
  final String splitName;
  final String ftpName;
  final String smsName;
  final int splitOrder;
  final double splitSpeed;
  final double legSpeed;
  final double distanceFromPreviousSplit;
  final double distanceFromPreviousLeg;
  final double distanceToNextSplit;
  final double distanceToNextLeg;
  final int genderPos;
  final int categoryPos;
  final int overallPos;
  final String tod;
  final String splitTime;
  final String raceTime;
  final String legTime;
  final String splitPace;
  final String legPace;
  final String estimatedNextLegRaceTime;
  final String estimatedNextSplitRaceTime;
  final String estimatedNextSplitTod;
  final String timeBehindOverallLeader;
  final String timeBehindGenderLeader;
  final String timeBehindCategoryLeader;

  AthleteResult({
    required this.athleteId,
    required this.eventId,
    this.alphaRaceNo,
    required this.bib,
    required this.firstName,
    required this.gender,
    required this.lastName,
    required this.raceNo,
    required this.countryRepresenting,
    required this.importKey,
    required this.leaderboardId,
    required this.category,
    required this.splitId,
    required this.splitName,
    required this.ftpName,
    required this.smsName,
    required this.splitOrder,
    required this.splitSpeed,
    required this.legSpeed,
    required this.distanceFromPreviousSplit,
    required this.distanceFromPreviousLeg,
    required this.distanceToNextSplit,
    required this.distanceToNextLeg,
    required this.genderPos,
    required this.categoryPos,
    required this.overallPos,
    required this.tod,
    required this.splitTime,
    required this.raceTime,
    required this.legTime,
    required this.splitPace,
    required this.legPace,
    required this.estimatedNextLegRaceTime,
    required this.estimatedNextSplitRaceTime,
    required this.estimatedNextSplitTod,
    required this.timeBehindOverallLeader,
    required this.timeBehindGenderLeader,
    required this.timeBehindCategoryLeader,
  });

  factory AthleteResult.fromJson(Map<String, dynamic> json) {
    return AthleteResult(
      athleteId: json['athlete_id'],
      eventId: json['event_id'],
      alphaRaceNo: json['alpha_race_no'],
      bib: json['bib'],
      firstName: json['first_name'],
      gender: Gender.fromJson(json['gender']),
      lastName: json['last_name'],
      raceNo: json['race_no'],
      countryRepresenting: Country.fromJson(json['country_representing']),
      importKey: json['import_key'],
      leaderboardId: json['leaderboard_id'],
      category: Category.fromJson(json['category']),
      splitId: json['split_id'],
      splitName: json['split_name'],
      ftpName: json['ftp_name'],
      smsName: json['sms_name'],
      splitOrder: json['split_order'],
      splitSpeed: json['split_speed'].toDouble(),
      legSpeed: json['leg_speed'].toDouble(),
      distanceFromPreviousSplit: json['distance_from_previous_split'].toDouble(),
      distanceFromPreviousLeg: json['distance_from_previous_leg'].toDouble(),
      distanceToNextSplit: json['distance_to_next_split'].toDouble(),
      distanceToNextLeg: json['distance_to_next_leg'].toDouble(),
      genderPos: json['gender_pos'],
      categoryPos: json['category_pos'],
      overallPos: json['overall_pos'],
      tod: json['tod'],
      splitTime: json['split_time'],
      raceTime: json['race_time'],
      legTime: json['leg_time'],
      splitPace: json['split_pace'],
      legPace: json['leg_pace'],
      estimatedNextLegRaceTime: json['estimated_next_leg_race_time'],
      estimatedNextSplitRaceTime: json['estimated_next_split_race_time'],
      estimatedNextSplitTod: json['estimated_next_split_tod'],
      timeBehindOverallLeader: json['time_behind_overall_leader'],
      timeBehindGenderLeader: json['time_behind_gender_leader'],
      timeBehindCategoryLeader: json['time_behind_category_leader'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Gender {
  final int id;
  final String name;
  final String code;

  Gender({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class Country {
  final int id;
  final String code;
  final String ioc;
  final String iso2;
  final String name;

  Country({
    required this.id,
    required this.code,
    required this.ioc,
    required this.iso2,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      code: json['code'],
      ioc: json['ioc'],
      iso2: json['iso2'],
      name: json['name'],
    );
  }
}

class Category {
  final int id;
  final int order;
  final String code;
  final dynamic spotterDescription;
  final String name;

  Category({
    required this.id,
    required this.order,
    required this.code,
    this.spotterDescription,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      order: json['order'],
      code: json['code'],
      spotterDescription: json['spotter_description'],
      name: json['name'],
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}