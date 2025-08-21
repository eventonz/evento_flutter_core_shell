import 'dart:convert';
import 'package:evento_core/core/utils/logger.dart';
import 'package:evento_core/core/models/miniplayer.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'advert.dart';

class AppConfig {
  AthleteDetails? athleteDetails;
  Home? home;
  Menu? menu;
  Athletes? athletes;
  Settings? settings;
  Tracking? tracking;
  Results? results;
  AppTheme? theme;
  MiniPlayerConfig? miniPlayerConfig;
  List<Advert>? adverts;

  AppConfig(
      {this.athleteDetails,
      this.home,
      this.menu,
      this.results,
      this.athletes,
      this.settings,
      this.tracking,
      this.adverts,
      this.theme});

  AppConfig.fromJson(Map<String, dynamic> json) {
    Logger.i('config');
    athleteDetails = json['athlete_details'] != null
        ? AthleteDetails.fromJson(json['athlete_details'])
        : null;
    home = json['home'] != null ? Home.fromJson(json['home']) : null;
    menu = json['menu'] != null ? Menu.fromJson(json['menu']) : null;
    results =
        json['results'] != null ? Results.fromJson(json['results']) : null;
    tracking =
        json['tracking'] != null ? Tracking.fromJson(json['tracking']) : null;
    athletes =
        json['athletes'] != null ? Athletes.fromJson(json['athletes']) : null;
    settings =
        json['settings'] != null ? Settings.fromJson(json['settings']) : null;

    theme = json['theme'] != null ? AppTheme.fromJson(json['theme']) : null;

    miniPlayerConfig = json['miniplayer'] != null
        ? MiniPlayerConfig.fromJson(json['miniplayer'][0])
        : null;
    adverts = json['adverts'] != null
        ? (json['adverts'] as List).map((e) => Advert.fromJson(e)).toList()
        : [];
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
    if (results != null) {
      data['results'] = results!.toJson();
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

  @override
  int get hashCode => super.hashCode;
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
  Shortcuts? shortcuts;

  Home({this.image, this.shortcuts});

  Home.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    shortcuts = json['shortcuts'] == null
        ? null
        : Shortcuts.fromJson(json['shortcuts']);
    /* Example JSON structure for reference:
    shortcuts = {
      "small": [
        {
          "icon": "shopping_bag",
          "title": "Home",
          "subtitle": "Go to homepage",
          "action": "openPage",
          "pageid":1512
        },
        {
          "icon": "shopping_bag",
          "backgroundGradient": {
            "startColor": "#9bafd9",
            "endColor": "#103783"
          },
          "title": "Settings",
          "subtitle": "Adjust your preferences",
          "action": "openPage",
          "pageid":1511
        },
        {
          "icon": "terrain",
          "title": "Find Athletes",
          "subtitle": "A complete list found here",
          "action": "openAthletes"
        }
      ],
      "large": [
        {
          "image": "https://i.ytimg.com/vi/P33IQ0KhnY0/hq720.jpg",
          "action": "openPage",
          "pageid": 2060
        },
        {
          "image": "https://i.ytimg.com/vi/Td6phSpGzlI/hq720.jpg",
          "action": "openAthletes"
        }
      ]
    }
    */
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    if (shortcuts != null) {
      data['shortcuts'] = shortcuts!.toJson();
    }
    return data;
  }
}

class Shortcuts {
  List<SmallShortcut>? small;
  List<LargeShortcut>? large;

  Shortcuts({this.small});

  Shortcuts.fromJson(Map<String, dynamic> json) {
    small = (json['small'] as List?)
        ?.map((e) => SmallShortcut.fromJson(e))
        .toList();
    large = (json['large'] as List?)
        ?.map((e) => LargeShortcut.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['small'] = small?.map((e) => e.toJson()).toList();
    data['large'] = large?.map((e) => e.toJson()).toList();
    return data;
  }
}

class SmallShortcut {
  String? icon;
  String? title;
  int? pageid;
  String? subtitle;
  String? action;
  String? url;
  BackgroundGradient? backgroundGradient;
  //Items? pageDetails;

  SmallShortcut(
      {this.icon,
      this.title,
      this.subtitle,
      this.action,
      this.url,
      this.backgroundGradient});

  SmallShortcut.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    title = json['title'];
    subtitle = json['subtitle'];
    action = json['action'];
    pageid = json['pageid'];
    url = json['url'];
    backgroundGradient = json['backgroundGradient'] == null
        ? null
        : BackgroundGradient.fromJson(json['backgroundGradient']);
    //pageDetails = json['pagedetails'] == null ? null : Items.fromJson(json['pagedetails']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icon'] = icon;
    data['title'] = title;
    data['subtitle'] = subtitle;
    data['action'] = action;
    data['url'] = url;
    data['backgroundGradient'] = backgroundGradient?.toJson();
    //data['pageDetails'] = pageDetails?.toJson();
    return data;
  }
}

class LargeShortcut {
  String? image;
  String? action;
  int? pageid;
  String? url;
  //Items? pageDetails;

  LargeShortcut({this.image, this.action, this.pageid, this.url});

  LargeShortcut.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    action = json['action'];
    pageid = json['pageid'];
    url = json['url'];
    //pageDetails = json['pagedetails'] == null ? null : Items.fromJson(json['pagedetails']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['action'] = action;
    data['pageid'] = pageid;
    data['url'] = url;
    //data['pageDetails'] = pageDetails?.toJson();
    return data;
  }
}

class PageDetails {
  String? icon;
  String? sourceId;
  int? id;
  String? type;
  String? title;

  PageDetails({this.icon, this.sourceId, this.id, this.type, this.title});

  PageDetails.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    sourceId = json['sourceId'];
    id = json['id'];
    type = json['type'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icon'] = icon;
    data['title'] = title;
    data['id'] = id;
    data['sourceId'] = sourceId;
    data['type'] = type;
    return data;
  }
}

class BackgroundGradient {
  String? startColor;
  String? endColor;

  BackgroundGradient({this.startColor, this.endColor});

  BackgroundGradient.fromJson(Map<String, dynamic> json) {
    startColor = json['startColor'];
    endColor = json['endColor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startColor'] = startColor;
    data['endColor'] = endColor;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Endpoint && other.url == url;
  }

  @override
  int get hashCode => super.hashCode;
}

class Items {
  String? type;
  String? linkType;
  String? supplier;
  int? sportSplitsRaceId;
  String? title;
  String? icon;
  bool? openExternal;
  bool? linkToDetail;
  int? id;
  String? sourceId;
  String? prefixprompt;
  String? assistantId;
  String? assistantBaseUrl;
  Endpoint? storySlider;
  Endpoint? link;
  Endpoint? pages;
  Endpoint? schedule;
  Endpoint? carousel;
  Endpoint? open;
  Endpoint? actions;
  List<int>? listEvents;

  Items(
      {this.type,
      this.title,
      this.icon,
      this.supplier,
      this.sportSplitsRaceId,
      this.linkToDetail,
      this.openExternal,
      this.prefixprompt,
      this.id,
      this.sourceId,
      this.assistantId,
      this.assistantBaseUrl,
      this.link,
      this.pages,
      this.storySlider,
      this.schedule,
      this.carousel,
      this.open,
      this.listEvents,
      this.actions});

  Items.fromJson(Map<String, dynamic> json) {
    linkType = json['link_type'];
    type = json['type'];
    title = json['title'];
    supplier = json['supplier'];
    sportSplitsRaceId = json['ss_raceid'] ?? json['sportsplits_raceid'];
    prefixprompt = json['prefixprompt'] ?? '';
    icon = json['icon'];
    openExternal = json['open_external'] ?? false;
    linkToDetail = json['opens_athlete_detail'] ?? false;
    id = json['id'];
    sourceId = json['sourceId'];
    assistantId = json['assistant_id'];
    assistantBaseUrl = json['assistant_base_url'];
    listEvents = (json['list_events'] as List?)?.map((e) => e as int).toList();
    link = json['link'] != null ? Endpoint.fromJson(json['link']) : null;
    pages = json['pages'] != null ? Endpoint.fromJson(json['pages']) : null;
    storySlider = json['storyslider'] != null
        ? Endpoint.fromJson(json['storyslider'])
        : null;
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
    data['supplier'] = supplier;
    data['sportsplits_raceid'] = sportSplitsRaceId;
    data['title'] = title;
    data['opens_athlete_detail'] = linkToDetail;
    data['icon'] = icon;
    data['open_external'] = openExternal;
    data['linktodetail'] = linkToDetail;
    data['id'] = id;
    data['sourceId'] = sourceId;
    data['assistant_id'] = assistantId;
    data['assistant_base_url'] = assistantBaseUrl;
    if (link != null) {
      data['link'] = link!.toJson();
    }
    if (storySlider != null) {
      data['storyslider'] = storySlider!.toJson();
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Items &&
        type == other.type &&
        linkType == other.linkType &&
        title == other.title &&
        icon == other.icon &&
        openExternal == other.openExternal &&
        id == other.id &&
        sourceId == other.sourceId &&
        storySlider == other.storySlider &&
        link == other.link &&
        pages == other.pages &&
        schedule == other.schedule &&
        carousel == other.carousel &&
        open == other.open &&
        actions == other.actions;
  }

  @override
  int get hashCode =>
      type.hashCode ^
      linkType.hashCode ^
      title.hashCode ^
      icon.hashCode ^
      openExternal.hashCode ^
      id.hashCode ^
      sourceId.hashCode ^
      storySlider.hashCode ^
      link.hashCode ^
      pages.hashCode ^
      schedule.hashCode ^
      carousel.hashCode ^
      open.hashCode ^
      actions.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tracking &&
        data == other.data &&
        updateFreq == other.updateFreq &&
        androidTracking == other.androidTracking &&
        mapMarkers == other.mapMarkers &&
        AppHelper.listsAreEqual(paths, other.paths); // Compare paths list
  }

  @override
  int get hashCode =>
      data.hashCode ^
      updateFreq.hashCode ^
      androidTracking.hashCode ^
      mapMarkers.hashCode ^
      paths.hashCode;
}

class Paths {
  String? color;
  String? url;
  String? name;

  Paths({this.url, this.name, this.color});

  Paths.fromJson(Map<String, dynamic> json) {
    url = json['geojson'] ?? json['url'];
    name = json['name'];
    color = json['path_color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geojson'] = url;
    data['name'] = name;
    data['color'] = color;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Paths && url == other.url && name == other.name;
  }

  @override
  int get hashCode => url.hashCode ^ name.hashCode;
}

class Results {
  bool? showResults;
  Items? config;

  Results({this.showResults, this.config});

  Results.fromJson(Map<String, dynamic> json) {
    showResults = json['show_results'];
    config = Items.fromJson(json['config']);
  }

  Map<String, dynamic> toJson() {
    return {
      'show_results': showResults,
      'config': config?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Results &&
        showResults == other.showResults &&
        config == other.config; // Compare paths list
  }

  @override
  int get hashCode => showResults.hashCode ^ config.hashCode;
}

class Athletes {
  String? edition;
  String? text;
  int? lastUpdated;
  String? follow;
  String? url;
  String? label;
  bool? showAthletes;

  Athletes(
      {this.edition,
      this.text,
      this.lastUpdated,
      this.follow,
      this.label,
      this.url,
      this.showAthletes});

  Athletes.fromJson(Map<String, dynamic> json) {
    edition = json['edition'];
    text = json['text'];
    lastUpdated = json['last_updated'];
    follow = json['follow'];
    url = json['url'];
    label = json['label'];
    showAthletes = json['show_athletes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['edition'] = edition;
    data['text'] = text;
    data['last_updated'] = lastUpdated;
    data['follow'] = follow;
    data['url'] = url;
    data['label'] = label;
    data['show_athletes'] = showAthletes;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Athletes &&
        edition == other.edition &&
        text == other.text &&
        lastUpdated == other.lastUpdated &&
        follow == other.follow &&
        url == other.url &&
        label == other.label &&
        showAthletes == other.showAthletes;
  }

  @override
  int get hashCode =>
      edition.hashCode ^
      text.hashCode ^
      lastUpdated.hashCode ^
      follow.hashCode ^
      url.hashCode ^
      label.hashCode ^
      showAthletes.hashCode;
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
