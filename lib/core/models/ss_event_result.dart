class SSEventResult {
  int? currentPage;
  int? from;
  String? firstPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  int? to;
  List<AthleteData>? data;

  SSEventResult({
    this.currentPage,
    this.from,
    this.firstPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.to,
    this.data,
  });

  factory SSEventResult.fromJson(Map<String, dynamic> json) {
    return SSEventResult(
      currentPage: json['current_page'],
      from: json['from'],
      firstPageUrl: json['first_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AthleteData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'first_page_url': firstPageUrl,
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'to': to,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class AthleteData {
  int? athleteId;
  Address? address;
  String? firstName;
  Gender? gender;
  Event? event;
  List<dynamic>? keywords;
  String? lastName;
  String? name;
  int? raceNo;
  Category? category;
  int? categoryPos;
  int? categoryPosFinishers;
  Club? club;
  Country? countryRepresenting;
  FinishStatus? finishStatus;
  int? genderPos;
  int? genderPosFinishers;
  String? importKey;
  int? netCategoryPos;
  int? netGenderPos;
  int? netOverallPos;
  int? overallPos;
  int? overallPosFinishers;
  Team? team1;
  Wave? wave;
  int? eventId;
  String? finishTime;
  String? netTime;
  String? startTod;
  String? finishTod;
  String? fastestLap;
  String? slowestLap;
  String? averageLap;
  String? lastLap;
  List<EstimatedSplit>? estimatedSplits;
  List<Split>? splits;

  AthleteData({
    this.athleteId,
    this.address,
    this.firstName,
    this.gender,
    this.event,
    this.keywords,
    this.lastName,
    this.name,
    this.raceNo,
    this.category,
    this.categoryPos,
    this.categoryPosFinishers,
    this.club,
    this.countryRepresenting,
    this.finishStatus,
    this.genderPos,
    this.genderPosFinishers,
    this.importKey,
    this.netCategoryPos,
    this.netGenderPos,
    this.netOverallPos,
    this.overallPos,
    this.overallPosFinishers,
    this.team1,
    this.wave,
    this.eventId,
    this.finishTime,
    this.netTime,
    this.startTod,
    this.finishTod,
    this.fastestLap,
    this.slowestLap,
    this.averageLap,
    this.lastLap,
    this.estimatedSplits,
    this.splits,
  });

  factory AthleteData.fromJson(Map<String, dynamic> json) {
    return AthleteData(
      athleteId: json['athlete_id'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      firstName: json['first_name'],
      gender: json['gender'] != null ? Gender.fromJson(json['gender']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      keywords: json['keywords'],
      lastName: json['last_name'],
      name: json['name'],
      raceNo: json['race_no'],
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      categoryPos: json['category_pos'],
      categoryPosFinishers: json['category_pos_finishers'],
      club: json['club'] != null ? Club.fromJson(json['club']) : null,
      countryRepresenting: json['country_representing'] != null ? Country.fromJson(json['country_representing']) : null,
      finishStatus: json['finish_status'] != null ? FinishStatus.fromJson(json['finish_status']) : null,
      genderPos: json['gender_pos'],
      genderPosFinishers: json['gender_pos_finishers'],
      importKey: json['import_key'],
      netCategoryPos: json['net_category_pos'],
      netGenderPos: json['net_gender_pos'],
      netOverallPos: json['net_overall_pos'],
      overallPos: json['overall_pos'],
      overallPosFinishers: json['overall_pos_finishers'],
      team1: json['team1'] != null ? Team.fromJson(json['team1']) : null,
      wave: json['wave'] != null ? Wave.fromJson(json['wave']) : null,
      eventId: json['event_id'],
      finishTime: json['finish_time'],
      netTime: json['net_time'],
      startTod: json['start_tod'],
      finishTod: json['finish_tod'],
      fastestLap: json['fastest_lap'],
      slowestLap: json['slowest_lap'],
      averageLap: json['average_lap'],
      lastLap: json['last_lap'],
      estimatedSplits: (json['estimated_splits'] as List<dynamic>?)
          ?.map((e) => EstimatedSplit.fromJson(e))
          .toList(),
      splits: (json['splits'] as List<dynamic>?)
          ?.map((e) => Split.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'athlete_id': athleteId,
      'address': address?.toJson(),
      'first_name': firstName,
      'gender': gender?.toJson(),
      'event': event?.toJson(),
      'keywords': keywords,
      'last_name': lastName,
      'name': name,
      'race_no': raceNo,
      'category': category?.toJson(),
      'category_pos': categoryPos,
      'category_pos_finishers': categoryPosFinishers,
      'club': club?.toJson(),
      'country_representing': countryRepresenting?.toJson(),
      'finish_status': finishStatus?.toJson(),
      'gender_pos': genderPos,
      'gender_pos_finishers': genderPosFinishers,
      'import_key': importKey,
      'net_category_pos': netCategoryPos,
      'net_gender_pos': netGenderPos,
      'net_overall_pos': netOverallPos,
      'overall_pos': overallPos,
      'overall_pos_finishers': overallPosFinishers,
      'team1': team1?.toJson(),
      'wave': wave?.toJson(),
      'event_id': eventId,
      'finish_time': finishTime,
      'net_time': netTime,
      'start_tod': startTod,
      'finish_tod': finishTod,
      'fastest_lap': fastestLap,
      'slowest_lap': slowestLap,
      'average_lap': averageLap,
      'last_lap': lastLap,
      'estimated_splits': estimatedSplits?.map((e) => e.toJson()).toList(),
      'splits': splits?.map((e) => e.toJson()).toList(),
    };
  }
}

class Address {
  Country? country;

  Address({
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country?.toJson(),
    };
  }
}

class Country {
  int? id;
  String? code;
  String? ioc;
  String? iso2;
  String? name;

  Country({
    this.id,
    this.code,
    this.ioc,
    this.iso2,
    this.name,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'ioc': ioc,
      'iso2': iso2,
      'name': name,
    };
  }
}

class Gender {
  int? id;
  String? name;
  String? code;

  Gender({
    this.id,
    this.name,
    this.code,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

class Event {
  int? id;
  String? name;
  String? date;

  Event({
    this.id,
    this.name,
    this.date,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
    };
  }
}

class Category {
  int? id;
  int? order;
  String? code;
  String? spotterDescription;
  String? name;

  Category({
    this.id,
    this.order,
    this.code,
    this.spotterDescription,
    this.name,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'code': code,
      'spotter_description': spotterDescription,
      'name': name,
    };
  }
}

class Club {
  int? id;
  String? code;
  String? name;

  Club({
    this.id,
    this.code,
    this.name,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class FinishStatus {
  int? id;
  int? order;
  String? code;
  String? webName;
  String? name;
  bool? published;

  FinishStatus({
    this.id,
    this.order,
    this.code,
    this.webName,
    this.name,
    this.published,
  });

  factory FinishStatus.fromJson(Map<String, dynamic> json) {
    return FinishStatus(
      id: json['id'],
      order: json['order'],
      code: json['code'],
      webName: json['web_name'],
      name: json['name'],
      published: json['published'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'code': code,
      'web_name': webName,
      'name': name,
      'published': published,
    };
  }
}

class Team {
  int? id;
  int? index;
  String? name;
  TeamType? type;
  String? penalty;
  String? finishTime;
  int? laps;
  String? fastestLap;
  String? slowestLap;
  String? averageLap;
  String? adjustment;
  int? distance;

  Team({
    this.id,
    this.index,
    this.name,
    this.type,
    this.penalty,
    this.finishTime,
    this.laps,
    this.fastestLap,
    this.slowestLap,
    this.averageLap,
    this.adjustment,
    this.distance,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    print('team');
    print(json);
    return Team(
      id: json['id'],
      index: json['index'],
      name: json['name'],
      type: json['type'] != null ? TeamType.fromJson(json['type']) : null,
      //penalty: json['penalty'],
      finishTime: json['finish_time'],
      laps: json['laps'],
      fastestLap: json['fastest_lap'],
      slowestLap: json['slowest_lap'],
      averageLap: json['average_lap'],
      adjustment: json['adjustment'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'index': index,
      'name': name,
      'type': type?.toJson(),
      'penalty': penalty,
      'finish_time': finishTime,
      'laps': laps,
      'fastest_lap': fastestLap,
      'slowest_lap': slowestLap,
      'average_lap': averageLap,
      'adjustment': adjustment,
      'distance': distance,
    };
  }
}

class TeamType {
  int? order;

  TeamType({
    this.order,
  });

  factory TeamType.fromJson(Map<String, dynamic> json) {
    return TeamType(
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
    };
  }
}

class Wave {
  int? id;
  int? order;
  String? description;
  bool? fromSplit;
  String? gunTime;
  String? approxTime;

  Wave({
    this.id,
    this.order,
    this.description,
    this.fromSplit,
    this.gunTime,
    this.approxTime,
  });

  factory Wave.fromJson(Map<String, dynamic> json) {
    return Wave(
      id: json['id'],
      order: json['order'],
      description: json['description'],
      fromSplit: json['from_split'],
      gunTime: json['gun_time'],
      approxTime: json['approx_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'description': description,
      'from_split': fromSplit,
      'gun_time': gunTime,
      'approx_time': approxTime,
    };
  }
}

class EstimatedSplit {
  int? splitId;
  int? order;
  String? name;
  double? distanceFromCurrentSplit;
  String? estimatedRaceTime;
  String? estimatedLegTime;
  String? estimatedTod;
  String? estimatedPace;
  double? estimatedSpeed;

  EstimatedSplit({
    this.splitId,
    this.order,
    this.name,
    this.distanceFromCurrentSplit,
    this.estimatedRaceTime,
    this.estimatedLegTime,
    this.estimatedTod,
    this.estimatedPace,
    this.estimatedSpeed,
  });

  factory EstimatedSplit.fromJson(Map<String, dynamic> json) {
    return EstimatedSplit(
      splitId: json['split_id'],
      order: json['order'],
      name: json['name'],
      distanceFromCurrentSplit: json['distance_from_current_split'],
      estimatedRaceTime: json['estimated_race_time'],
      estimatedLegTime: json['estimated_leg_time'],
      estimatedTod: json['estimated_tod'],
      estimatedPace: json['estimated_pace'],
      estimatedSpeed: json['estimated_speed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_id': splitId,
      'order': order,
      'name': name,
      'distance_from_current_split': distanceFromCurrentSplit,
      'estimated_race_time': estimatedRaceTime,
      'estimated_leg_time': estimatedLegTime,
      'estimated_tod': estimatedTod,
      'estimated_pace': estimatedPace,
      'estimated_speed': estimatedSpeed,
    };
  }
}

class Split {
  int? splitId;
  int? order;
  String? name;
  int? typeId;
  int? overallPos;
  int? genderPos;
  int? categoryPos;
  SplitDetail? split;

  Split({
    this.splitId,
    this.order,
    this.name,
    this.typeId,
    this.overallPos,
    this.genderPos,
    this.categoryPos,
    this.split,
  });

  factory Split.fromJson(Map<String, dynamic> json) {
    return Split(
      splitId: json['split_id'],
      order: json['order'],
      name: json['name'],
      typeId: json['type_id'],
      overallPos: json['overall_pos'],
      genderPos: json['gender_pos'],
      categoryPos: json['category_pos'],
      split: json['split'] != null ? SplitDetail.fromJson(json['split']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_id': splitId,
      'order': order,
      'name': name,
      'type_id': typeId,
      'overall_pos': overallPos,
      'gender_pos': genderPos,
      'category_pos': categoryPos,
      'split': split?.toJson(),
    };
  }
}

class SplitDetail {
  int? splitId;
  bool? api;
  int? calculationTypeId;
  String? commentatorName;
  double? distanceFromPreviousLeg;
  double? distanceFromPreviousSplit;
  double? distanceFromStart;
  double? distanceToFinish;
  double? distanceToNextLeg;
  double? distanceToNextSplit;
  String? ftpName;
  bool? fullResults;
  bool? individualResults;
  bool? isHidden;
  bool? landingPage;
  int? lapNo;
  bool? leaderboard;
  Leg? leg;
  String? name;
  int? order;
  String? smsName;
  String? timerName;
  int? typeId;

  SplitDetail({
    this.splitId,
    this.api,
    this.calculationTypeId,
    this.commentatorName,
    this.distanceFromPreviousLeg,
    this.distanceFromPreviousSplit,
    this.distanceFromStart,
    this.distanceToFinish,
    this.distanceToNextLeg,
    this.distanceToNextSplit,
    this.ftpName,
    this.fullResults,
    this.individualResults,
    this.isHidden,
    this.landingPage,
    this.lapNo,
    this.leaderboard,
    this.leg,
    this.name,
    this.order,
    this.smsName,
    this.timerName,
    this.typeId,
  });

  factory SplitDetail.fromJson(Map<String, dynamic> json) {
    return SplitDetail(
      splitId: json['split_id'],
      api: json['api'],
      calculationTypeId: json['calculation_type_id'],
      commentatorName: json['commentator_name'],
      distanceFromPreviousLeg: json['distance_from_previous_leg'],
      distanceFromPreviousSplit: json['distance_from_previous_split'],
      distanceFromStart: json['distance_from_start'],
      distanceToFinish: json['distance_to_finish'],
      distanceToNextLeg: json['distance_to_next_leg'],
      distanceToNextSplit: json['distance_to_next_split'],
      ftpName: json['ftp_name'],
      fullResults: json['full_results'],
      individualResults: json['individual_results'],
      isHidden: json['is_hidden'],
      landingPage: json['landing_page'],
      lapNo: json['lap_no'],
      leaderboard: json['leaderboard'],
      leg: json['leg'] != null ? Leg.fromJson(json['leg']) : null,
      name: json['name'],
      order: json['order'],
      smsName: json['sms_name'],
      timerName: json['timer_name'],
      typeId: json['type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_id': splitId,
      'api': api,
      'calculation_type_id': calculationTypeId,
      'commentator_name': commentatorName,
      'distance_from_previous_leg': distanceFromPreviousLeg,
      'distance_from_previous_split': distanceFromPreviousSplit,
      'distance_from_start': distanceFromStart,
      'distance_to_finish': distanceToFinish,
      'distance_to_next_leg': distanceToNextLeg,
      'distance_to_next_split': distanceToNextSplit,
      'ftp_name': ftpName,
      'full_results': fullResults,
      'individual_results': individualResults,
      'is_hidden': isHidden,
      'landing_page': landingPage,
      'lap_no': lapNo,
      'leaderboard': leaderboard,
      'leg': leg?.toJson(),
      'name': name,
      'order': order,
      'sms_name': smsName,
      'timer_name': timerName,
      'type_id': typeId,
    };
  }
}

class Leg {
  int? id;
  String? name;

  Leg({
    this.id,
    this.name,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
