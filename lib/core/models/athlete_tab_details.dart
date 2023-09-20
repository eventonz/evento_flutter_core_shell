class AthleteTabDetailM {
  late String openTab;
  Tabs? tabs;
  late List<String> order;

  AthleteTabDetailM({this.openTab = '', this.tabs, this.order = const []});

  AthleteTabDetailM.fromJson(Map<String, dynamic> json) {
    openTab = json['open_tab'] = '';
    tabs = json['tabs'] != null ? Tabs.fromJson(json['tabs']) : null;
    order = json['order']?.cast<String>() ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open_tab'] = openTab;
    if (tabs != null) {
      data['tabs'] = tabs!.toJson();
    }
    data['order'] = order;
    return data;
  }
}

class Tabs {
  late List<Splits> splits;
  Summary? summary;

  Tabs({this.splits = const [], this.summary});

  Tabs.fromJson(Map<String, dynamic> json) {
    if (json['splits'] != null) {
      splits = <Splits>[];
      json['splits'].forEach((v) {
        splits.add(Splits.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? Summary.fromJson(json['summary']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['splits'] = splits.map((v) => v.toJson()).toList();
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    return data;
  }
}

class Splits {
  List<String>? data;
  String? style;

  Splits({this.data, this.style});

  Splits.fromJson(Map<String, dynamic> json) {
    data = json['data'].cast<String>();
    style = json['style'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['style'] = style;
    return data;
  }
}

class Summary {
  List<DataList>? list;
  Top? top;

  Summary({this.list, this.top});

  Summary.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <DataList>[];
      json['list'].forEach((v) {
        list!.add(DataList.fromJson(v));
      });
    }
    top = json['top'] != null ? Top.fromJson(json['top']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    if (top != null) {
      data['top'] = top!.toJson();
    }
    return data;
  }
}

class DataList {
  String? icon;
  String? name;
  String? value;

  DataList({this.icon, this.name, this.value});

  DataList.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icon'] = icon;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class Top {
  String? medal;
  late List<InfoBar> infoBar;
  String? subtitle;
  String? result;

  Top({this.medal, this.infoBar = const [], this.subtitle, this.result});

  Top.fromJson(Map<String, dynamic> json) {
    medal = json['medal'];
    if (json['info_bar'] != null) {
      infoBar = <InfoBar>[];
      json['info_bar'].forEach((v) {
        infoBar.add(InfoBar.fromJson(v));
      });
    } else {
      json['info_bar'] = [];
    }
    subtitle = json['subtitle'];
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['medal'] = medal;
    data['info_bar'] = infoBar.map((v) => v.toJson()).toList();
    data['subtitle'] = subtitle;
    data['result'] = result;
    return data;
  }
}

class InfoBar {
  late String name;
  late String value;

  InfoBar({this.name = '', this.value = ''});

  InfoBar.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    value = json['value'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}
