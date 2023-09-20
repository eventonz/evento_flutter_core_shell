class EventOffersM {
  bool? random;
  List<EventOffer>? eventOffer;

  EventOffersM({this.random, this.eventOffer});

  EventOffersM.fromJson(Map<String, dynamic> json) {
    random = json['random'];
    if (json['items'] != null) {
      eventOffer = <EventOffer>[];
      json['items'].forEach((v) {
        eventOffer!.add(EventOffer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['random'] = random;
    if (eventOffer != null) {
      data['items'] = eventOffer!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventOffer {
  String? content;
  List<Buttons>? buttons;
  Media? media;
  String? title;

  EventOffer({this.content, this.buttons, this.media, this.title});

  EventOffer.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    if (json['buttons'] != null) {
      buttons = <Buttons>[];
      json['buttons'].forEach((v) {
        buttons!.add(Buttons.fromJson(v));
      });
    }
    media = json['media'] != null ? Media.fromJson(json['media']) : null;
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    if (buttons != null) {
      data['buttons'] = buttons!.map((v) => v.toJson()).toList();
    }
    if (media != null) {
      data['media'] = media!.toJson();
    }
    data['title'] = title;
    return data;
  }
}

class Buttons {
  String? type;
  Label? label;
  SocialMedia? socialMedia;

  Buttons({this.type, this.label, this.socialMedia});

  Buttons.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    label = json['label'] != null ? Label.fromJson(json['label']) : null;
    socialMedia = json['social_media'] != null
        ? SocialMedia.fromJson(json['social_media'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (label != null) {
      data['label'] = label!.toJson();
    }
    if (socialMedia != null) {
      data['social_media'] = socialMedia!.toJson();
    }
    return data;
  }
}

class Label {
  String? text;
  String? open;

  Label({this.text, this.open});

  Label.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    open = json['open'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['open'] = open;
    return data;
  }
}

class SocialMedia {
  String? medium;
  String? open;

  SocialMedia({this.medium, this.open});

  SocialMedia.fromJson(Map<String, dynamic> json) {
    medium = json['medium'];
    open = json['open'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['medium'] = medium;
    data['open'] = open;
    return data;
  }
}

class Media {
  OfferImage? image;
  String? type;

  Media({this.image, this.type});

  Media.fromJson(Map<String, dynamic> json) {
    image = json['image'] != null ? OfferImage.fromJson(json['image']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (image != null) {
      data['image'] = image!.toJson();
    }
    data['type'] = type;
    return data;
  }
}

class OfferImage {
  String? url;

  OfferImage({this.url});

  OfferImage.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
