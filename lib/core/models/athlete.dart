class AthletesM {
  String? created;
  List<Entrants>? entrants;

  AthletesM({this.created, this.entrants});

  AthletesM.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    if (json['entrants'] != null) {
      entrants = <Entrants>[];
      json['entrants'].forEach((v) {
        entrants!.add(Entrants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created'] = created;
    if (entrants != null) {
      data['entrants'] = entrants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entrants {
  late String info;
  late String number;
  late String name;
  late String profileImage;
  late String id;
  late String disRaceNo;
  late int contest;
  late String extra;
  late bool canFollow;
  List<AthleteDetails>? athleteDetails;

  Entrants(
      {this.info = '',
      this.number = '',
      this.name = '',
      this.profileImage = '',
      this.disRaceNo = '',
      this.id = '-1',
      this.contest = -1,
      this.extra = '',
      this.canFollow = true});

  Entrants.fromJson(Map<String, dynamic> json) {
    print(json);
    info = json['info'] ?? '';
    number = json['number'] ?? '';
    name = json['name'] ?? '';
    profileImage = json['profile_image'] ?? '';
    id = json['id'] ?? '-1';
    contest = json['contest'] ?? -1;
    extra = json['extra'] ?? '';
    disRaceNo = json['disRaceNo'] ?? '';
    canFollow = json['can_follow'] ?? true;
    if (json['athlete_details'] != null) {
      athleteDetails = <AthleteDetails>[];
      json['athlete_details'].forEach((v) {
        athleteDetails!.add(AthleteDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['info'] = info;
    data['number'] = number;
    data['name'] = name;
    data['profile_image'] = profileImage;
    data['id'] = id;
    data['contest'] = contest;
    data['disRaceNo'] = disRaceNo;
    data['extra'] = extra;
    if (athleteDetails != null) {
      data['athlete_details'] = athleteDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AthleteDetails {
  late String name;
  late String country;
  late String athleteNumber;

  AthleteDetails({this.name = '', this.country = '', this.athleteNumber = ''});

  AthleteDetails.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    country = json['country'] ?? '';
    athleteNumber = json['athletenumber'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['country'] = country;
    data['athletenumber'] = athleteNumber;
    return data;
  }
}
