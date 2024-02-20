class EventResultsM {
  List<EventResult>? eventResult;

  EventResultsM({this.eventResult});

  EventResultsM.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      eventResult = <EventResult>[];
      json['items'].forEach((v) {
        eventResult!.add(EventResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (eventResult != null) {
      data['items'] = eventResult!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EventResult {
  Detail? detail;
  ListTitle? listTitle;

  EventResult({this.detail, this.listTitle});

  EventResult.fromJson(Map<String, dynamic> json) {
    detail = json['detail'] != null ? Detail.fromJson(json['detail']) : null;
    listTitle = json['list'] != null ? ListTitle.fromJson(json['list']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    if (listTitle != null) {
      data['list'] = listTitle!.toJson();
    }
    return data;
  }
}

class Detail {
  Embed? embed;
  Content? content;
  String? type;

  Detail({this.embed, this.content, this.type});

  Detail.fromJson(Map<String, dynamic> json) {
    embed = json['embed'] != null ? Embed.fromJson(json['embed']) : null;
    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (embed != null) {
      data['embed'] = embed!.toJson();
    }
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['type'] = type;
    return data;
  }
}

class Embed {
  String? url;
  String? linkType;

  Embed({this.url, this.linkType});

  Embed.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    linkType = json['link_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['link_type'] = linkType;
    return data;
  }
}

class Content {
  String? title;
  String? content;
  String? image;

  Content({this.title, this.content, this.image});

  Content.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['image'] = image;
    return data;
  }
}

class ListTitle {
  String? title;
  String? subtitle;
  String? thumbnail;

  ListTitle({this.title, this.subtitle, this.thumbnail});

  ListTitle.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    subtitle = json['subtitle'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
