class ChallengeInfoM {
  String? title;
  String? content;
  Media? media;
  List<Buttons>? buttons;

  ChallengeInfoM({this.title, this.content, this.media, this.buttons});

  ChallengeInfoM.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    media = json['media'] != null ? Media.fromJson(json['media']) : null;
    if (json['buttons'] != null) {
      buttons = <Buttons>[];
      json['buttons'].forEach((v) {
        buttons!.add(Buttons.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    if (media != null) {
      data['media'] = media!.toJson();
    }
    if (buttons != null) {
      data['buttons'] = buttons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Media {
  String? type;
  Image? image;

  Media({this.type, this.image});

  Media.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    return data;
  }
}

class Image {
  String? url;

  Image({this.url});

  Image.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}

class Buttons {
  String? location;
  String? type;
  String? color;
  Label? label;
  String? open;

  Buttons({this.location, this.type, this.color, this.label, this.open});

  Buttons.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    type = json['type'];
    color = json['color'];
    label = json['label'] != null ? Label.fromJson(json['label']) : null;
    open = json['open'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['type'] = type;
    data['color'] = color;
    if (label != null) {
      data['label'] = label!.toJson();
    }
    data['open'] = open;
    return data;
  }
}

class Label {
  String? text;
  String? color;

  Label({this.text, this.color});

  Label.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['color'] = color;
    return data;
  }
}
