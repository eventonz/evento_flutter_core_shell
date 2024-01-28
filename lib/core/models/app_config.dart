import 'package:evento_core/core/models/miniplayer.dart';

import 'advert.dart';

class AppConfig {
  AthleteDetails? athleteDetails;
  Home? home;
  Menu? menu;
  Athletes? athletes;
  Settings? settings;
  Tracking? tracking;
  AppTheme? theme;
  MiniPlayerConfig? miniPlayerConfig;
  List<Advert>? adverts;

  AppConfig(
      {this.athleteDetails,
      this.home,
      this.menu,
      this.athletes,
      this.settings,
      this.tracking,
      this.adverts,
      this.theme});

  AppConfig.fromJson(Map<String, dynamic> json) {
    athleteDetails = json['athlete_details'] != null
        ? AthleteDetails.fromJson(json['athlete_details'])
        : null;
    home = json['home'] != null ? Home.fromJson(json['home']) : null;
    menu = json['menu'] != null ? Menu.fromJson(json['menu']) : null;
    tracking =
        json['tracking'] != null ? Tracking.fromJson(json['tracking']) : null;
    athletes =
        json['athletes'] != null ? Athletes.fromJson(json['athletes']) : null;
    settings =
        json['settings'] != null ? Settings.fromJson(json['settings']) : null;

    theme = json['theme'] != null ? AppTheme.fromJson(json['theme']) : null;
    print(json['miniplayer']);

    miniPlayerConfig = json['miniplayer'] != null ? MiniPlayerConfig.fromJson(json['miniplayer'][0]) : null;
    adverts = json['adverts'] != null ? (json['adverts'] as List).map((e) => Advert.fromJson(e)).toList() : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (athleteDetails != null) {
      data['athlete_details'] = athleteDetails!.toJson();
    }
    if (home != null) {
      data['home'] = home!.toJson();
    }
    if (menu != null) {
      data['menu'] = menu!.toJson();
    }
    if (athletes != null) {
      data['athletes'] = athletes!.toJson();
    }
    if (settings != null) {
      data['settings'] = settings!.toJson();
    }
    if (tracking != null) {
      data['tracking'] = tracking!.toJson();
    }
    if (theme != null) {
      data['theme'] = theme!.toJson();
    }
    if (miniPlayerConfig != null) {
      data['mini_player'] = miniPlayerConfig!.toJson();
    }
    if (adverts != null) {
      data['adverts'] = adverts?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class AthleteDetails {
  int? version;
  String? url;

  AthleteDetails({this.version, this.url});

  AthleteDetails.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['url'] = url;
    return data;
  }
}

class Home {
  String? image;

  Home({this.image});

  Home.fromJson(Map<String, dynamic> json) {
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    return data;
  }
}

class Menu {
  Endpoint? endpoint;
  String? created;
  List<Items>? items;

  Menu({this.endpoint, this.created, this.items});

  Menu.fromJson(Map<String, dynamic> json) {
    created = json['created'];
    endpoint =
        json['endpoint'] != null ? Endpoint.fromJson(json['endpoint']) : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created'] = created;
    if (endpoint != null) {
      data['endpoint'] = endpoint!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Endpoint {
  String? url;

  Endpoint({this.url});

  Endpoint.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}

class Items {
  String? type;
  String? linkType;
  String? title;
  String? icon;
  bool? openExternal;
  int? id;
  String? sourceId;
  Endpoint? link;
  Endpoint? pages;
  Endpoint? schedule;
  Endpoint? carousel;
  Endpoint? open;
  Endpoint? actions;

  Items(
      {this.type,
      this.title,
      this.icon,
      this.openExternal,
      this.id,
      this.sourceId,
      this.link,
      this.pages,
      this.schedule,
      this.carousel,
      this.open,
      this.actions});

  Items.fromJson(Map<String, dynamic> json) {
    linkType = json['link_type'];
    type = json['type'];
    title = json['title'];
    icon = json['icon'];
    openExternal = json['open_external'];
    id = json['id'];
    sourceId = json['sourceId'];
    link = json['link'] != null ? Endpoint.fromJson(json['link']) : null;
    pages = json['pages'] != null ? Endpoint.fromJson(json['pages']) : null;
    schedule =
        json['schedule'] != null ? Endpoint.fromJson(json['schedule']) : null;
    carousel =
        json['carousel'] != null ? Endpoint.fromJson(json['carousel']) : null;
    open = json['open'] != null ? Endpoint.fromJson(json['actions']) : null;
    actions =
        json['actions'] != null ? Endpoint.fromJson(json['actions']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['link_type'] = linkType;
    data['type'] = type;
    data['title'] = title;
    data['icon'] = icon;
    data['open_external'] = openExternal;
    data['id'] = id;
    data['sourceId'] = sourceId;
    if (link != null) {
      data['link'] = link!.toJson();
    }
    if (pages != null) {
      data['pages'] = pages!.toJson();
    }
    if (schedule != null) {
      data['schedule'] = schedule!.toJson();
    }
    if (carousel != null) {
      data['carousel'] = carousel!.toJson();
    }
    if (actions != null) {
      data['actions'] = actions!.toJson();
    }
    if (actions != null) {
      data['actions'] = actions!.toJson();
    }
    return data;
  }
}

class Tracking {
  String? data;
  int? updateFreq;
  bool? androidTracking;
  String? mapMarkers;
  List<Paths> paths = [];

  Tracking(
      {this.data,
      this.updateFreq,
      this.androidTracking,
      this.mapMarkers,
      this.paths = const []});

  Tracking.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    updateFreq = json['update_freq'];
    androidTracking = json['android_tracking'];
    mapMarkers = json['map_markers'];
    if (json['paths'] != null) {
      paths = <Paths>[];
      json['paths'].forEach((v) {
        paths.add(Paths.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['update_freq'] = updateFreq;
    data['android_tracking'] = androidTracking;
    data['map_markers'] = mapMarkers;
    data['paths'] = paths.map((v) => v.toJson()).toList();
    return data;
  }
}

class Paths {
  String? url;
  String? name;

  Paths({this.url, this.name});

  Paths.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['name'] = name;
    return data;
  }
}

class Athletes {
  String? edition;
  String? text;
  int? lastUpdated;
  String? follow;
  String? url;
  bool? showAthletes;

  Athletes(
      {this.edition,
      this.text,
      this.lastUpdated,
      this.follow,
      this.url,
      this.showAthletes});

  Athletes.fromJson(Map<String, dynamic> json) {
    edition = json['edition'];
    text = json['text'];
    lastUpdated = json['last_updated'];
    follow = json['follow'];
    url = json['url'];
    showAthletes = json['show_athletes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['edition'] = edition;
    data['text'] = text;
    data['last_updated'] = lastUpdated;
    data['follow'] = follow;
    data['url'] = url;
    data['show_athletes'] = showAthletes;
    return data;
  }
}

class Settings {
  Segmenting? segmenting;
  List<Notifications>? notifications;

  Settings({this.segmenting, this.notifications});

  Settings.fromJson(Map<String, dynamic> json) {
    segmenting = json['segmenting'] != null
        ? Segmenting.fromJson(json['segmenting'])
        : null;
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (segmenting != null) {
      data['segmenting'] = segmenting!.toJson();
    }
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Segmenting {
  String? effectsOn;
  bool? show;
  String? question;

  Segmenting({this.effectsOn, this.show, this.question});

  Segmenting.fromJson(Map<String, dynamic> json) {
    effectsOn = json['effects_on'];
    show = json['show'];
    question = json['question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['effects_on'] = effectsOn;
    data['show'] = show;
    data['question'] = question;
    return data;
  }
}

class Notifications {
  String? text;
  String? id;
  bool? checkbox;

  Notifications({this.text, this.id, this.checkbox});

  Notifications.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    id = json['id'];
    checkbox = json['checkbox'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['id'] = id;
    data['checkbox'] = checkbox;
    return data;
  }
}

class AppTheme {
  Accent? accent;

  AppTheme({this.accent});

  AppTheme.fromJson(Map<String, dynamic> json) {
    accent = json['accent'] != null ? Accent.fromJson(json['accent']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (accent != null) {
      data['accent'] = accent!.toJson();
    }
    return data;
  }
}

class Accent {
  String? light;
  String? dark;

  Accent({this.light, this.dark});

  Accent.fromJson(Map<String, dynamic> json) {
    light = json['light'];
    dark = json['dark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['light'] = light;
    data['dark'] = dark;
    return data;
  }
}
