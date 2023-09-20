class EventM {
  List<Event>? events;
  Header? header;

  EventM({this.events, this.header});

  EventM.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      events = <Event>[];
      json['items'].forEach((v) {
        events!.add(Event.fromJson(v));
      });
    }
    header = json['header'] != null ? Header.fromJson(json['header']) : null;
  }
}

class Event {
  String? largeImage;
  bool? open;
  Tag? tag;
  late String size;
  int? id;
  String? config;
  String? type;
  late String subtitle;
  late String title;
  String? smallImage;
  List<SubEvents>? subEvents;
  String? header;

  Event(
      {this.largeImage,
      this.open,
      this.tag,
      this.size = 'small',
      this.id,
      this.config,
      this.type,
      this.subtitle = 'dsd',
      this.title = '',
      this.smallImage,
      this.header});

  Event.fromJson(Map<String, dynamic> json) {
    largeImage = json['large_image'];
    open = json['open'];
    tag = json['tag'] != null ? Tag.fromJson(json['tag']) : null;
    size = json['size'] ?? 'small';
    id = json['id'];
    config = json['config'];
    type = json['type'] ?? '';
    subtitle = json['subtitle'] ?? '';
    title = json['title'];
    smallImage = json['small_image'];
    if (json['events'] != null) {
      subEvents = <SubEvents>[];
      json['events'].forEach((v) {
        subEvents!.add(SubEvents.fromJson(v));
      });
    }
    header = json['header'];
  }
}

class Tag {
  late String text;
  String? color;
  late bool blinking;

  Tag({this.text = '', this.color, this.blinking = false});

  Tag.fromJson(Map<String, dynamic> json) {
    text = json['text'] ?? '';
    color = json['color'];
    blinking = json['blinking'] ?? false;
  }
}

class SubEvents {
  String? image;
  int? id;
  String? config;
  String? subtitle;
  String? title;
  String? subtitle2;
  bool? live;
  String? size;

  SubEvents(
      {this.image,
      this.id,
      this.config,
      this.subtitle,
      this.title,
      this.subtitle2,
      this.live,
      this.size});

  SubEvents.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    id = json['id'];
    config = json['config'];
    subtitle = json['subtitle'];
    title = json['title'];
    subtitle2 = json['subtitle2'];
    live = json['live'];
    size = json['size'];
  }
}

class Header {
  String? logo;
  String? color;

  Header({this.logo, this.color});

  Header.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    color = json['color'];
  }
}
