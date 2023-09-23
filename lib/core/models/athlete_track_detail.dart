class TrackDetail {
  List<AthleteTrackDetail>? tracks;

  TrackDetail({this.tracks});

  TrackDetail.fromJson(Map<String, dynamic> json) {
    if (json['tracks'] != null) {
      tracks = <AthleteTrackDetail>[];
      json['tracks'].forEach((v) {
        tracks!.add(AthleteTrackDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tracks != null) {
      data['tracks'] = tracks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AthleteTrackDetail {
  String? track;
  String? info;
  double? speed;
  double? location;
  double? prevLocation;
  String? path;
  String? status;
  String? markerText;

  AthleteTrackDetail(
      {this.track,
      this.info,
      this.speed,
      this.location,
      this.prevLocation,
      this.path,
      this.status,
      this.markerText});

  AthleteTrackDetail.fromJson(Map<String, dynamic> json) {
    track = json['track'];
    info = json['info'];
    speed = json['speed'].toDouble();
    location = json['location'].toDouble();
    prevLocation = json['prev_location']?.toDouble();
    path = json['path'];
    status = json['status'];
    markerText = json['marker_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['track'] = track;
    data['info'] = info;
    data['speed'] = speed;
    data['location'] = location;
    data['prev_location'] = prevLocation;
    data['path'] = path;
    data['status'] = status;
    data['marker_text'] = markerText;
    return data;
  }
}
