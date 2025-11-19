class ScheduleM {
  ScheduleData? schedule;

  ScheduleM({this.schedule});

  ScheduleM.fromJson(Map<String, dynamic> json) {
    schedule = json['schedule'] != null
        ? ScheduleData.fromJson(json['schedule'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (schedule != null) {
      data['schedule'] = schedule!.toJson();
    }
    return data;
  }
}

class ScheduleData {
  List<ScheduleDataItems>? items;
  List<String>? tags;

  ScheduleData({this.items, this.tags});

  ScheduleData.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <ScheduleDataItems>[];
      json['items'].forEach((v) {
        items!.add(ScheduleDataItems.fromJson(v));
      });
    }
    tags = json['tags'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['tags'] = tags;
    return data;
  }
}

class ScheduleDataItems {
  String? content;
  String? startTime;
  Location? location;
  String? datetime;
  String? endTime;
  bool? highlighted;
  String? title;
  List<String>? tags;

  ScheduleDataItems(
      {this.content,
      this.startTime,
      this.location,
      this.datetime,
      this.endTime,
      this.highlighted,
      this.title,
      this.tags});

  ScheduleDataItems.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    startTime = json['start_time'] ?? '';
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    datetime = json['datetime'];
    endTime = json['end_time'] ?? '';
    highlighted = json['highlighted'];
    title = json['title'];
    tags = json['tags'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['start_time'] = startTime;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['datetime'] = datetime;
    data['end_time'] = endTime;
    data['highlighted'] = highlighted;
    data['title'] = title;
    data['tags'] = tags;
    return data;
  }
}

class Location {
  Coordinate? coordinate;
  String? title;

  Location({this.coordinate, this.title});

  Location.fromJson(Map<String, dynamic> json) {
    coordinate = json['coordinate'] != null
        ? Coordinate.fromJson(json['coordinate'])
        : null;
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coordinate != null) {
      data['coordinate'] = coordinate!.toJson();
    }
    data['title'] = title;
    return data;
  }
}

class Coordinate {
  double? longitude;
  double? latitude;

  Coordinate({this.longitude, this.latitude});

  Coordinate.fromJson(Map<String, dynamic> json) {
    longitude = json['longitude'].toDouble();
    latitude = json['latitude'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}
