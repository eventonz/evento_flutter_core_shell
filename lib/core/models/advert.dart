class Advert {
  String? id;
  String? type;
  String? openUrl;
  String? image;
  String? frequency;

  Advert({this.openUrl});

  Advert.fromJson(Map<String, dynamic> json) {
    print(json);
    id = json['id'];
    type = json['type'];
    openUrl = json['open_url'];
    image = json['image'];
    frequency = json['frequency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open_url'] = openUrl;
    return data;
  }
}

class AdvertFrequency {
  static const String daily = 'daily';
  static const String everyOpen = 'everyopen';
}

class AdvertType {
  static const String banner = 'Banner';
  static const String splash = 'Splash';
}
