import 'athlete_tab_details.dart';

class DetailItem {

  String? type;
  dynamic data;
  List<Splits>? splits;
  List<String>? columns;
  List<SegmentedSplitSegments>? segments;

  DetailItem.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if(type == 'summary') {
      data = SummaryData.fromJson(json['data']);
    } else if(type == 'externallinks') {
      data = json['data'].map<ExternalLinkData>((e) => ExternalLinkData.fromJson(e)).toList();
    } else if(type == 'pace') {
      data = json['data'].map<PaceData>((e) => PaceData.fromJson(e)).toList();
    } else if(type == 'title') {
      data = TitleData.fromJson(json['data']);
    } else if(type == 'splits') {
      splits = json['splits'].map<Splits>((e) => Splits.fromJson(e)).toList();
    } else if(type == 'segmentedsplit') {
     /*
    json['data'].insert(4, {
        "values": [
          "*bold*Swim Leg",
          " ",
          "00:00",
        ],
        "point": "static",
        "style": "split_green",
      });

      json['data'].insert(2, {
        "values": [
          "Swim Leg",
          " ",
          "00:00",
        ],
        "point": "static",
 
      });
      */

      data = json['data'].map<SegmentedSplitData>((e) => SegmentedSplitData.fromJson(e)).toList();
      segments = json['segments'].map<SegmentedSplitSegments>((e) => SegmentedSplitSegments.fromJson(e)).toList();
      columns = json['columns'].map<String>((e) => e as String).toList();
    }
  }
}

class SummaryData {
  SummaryDataTop? top;
  SummaryData.fromJson(Map<String, dynamic> json) {
    top = SummaryDataTop.fromJson(json['top']);
  }
}

class SummaryDataTop {

  String? medal;
  String? subtitle;
  String? result;
  List<SummaryDataTopInfoBar> infoBar = [];

  SummaryDataTop.fromJson(Map<String, dynamic> json) {
    infoBar = json['info_bar'].map<SummaryDataTopInfoBar>((e) => SummaryDataTopInfoBar.fromJson(e)).toList();
    medal = json['medal'];
    subtitle = json['subtitle'];
    result = json['result'];
  }
}

class SummaryDataTopInfoBar {
  late String name;
  late String value;

  SummaryDataTopInfoBar({this.name = '', this.value = ''});

  SummaryDataTopInfoBar.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}

class ExternalLinkData {

  String? icon;
  String? url;
  String? label;

  ExternalLinkData.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    url = json['url'];
    label = json['label'];
  }
}

class TitleData {
  String? label;

  TitleData.fromJson(Map<String, dynamic> json) {
    label = json['label'];
  }
}

class PaceData {
  String? range;
  String? icon;
  String? time;
  int? value;

  PaceData.fromJson(Map<String, dynamic> json) {
    range = json['range'];
    icon = json['icon'];
    time = json['time'];
    value = json['value'];
  }
}

class SegmentedSplitData {
  int? index;
  String? style;
  String? point;
  List<String>? values;

  SegmentedSplitData.fromJson(Map<String, dynamic> json) {
    point = json['point'];
    style = json['style'];
    values = json['values'].map<String>((e) => e as String).toList();;
  }
}

class SegmentedSplitSegments {
  String? name;
  List<String>? columns;

  SegmentedSplitSegments.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    columns = json['columns'].map<String>((e) => e as String).toList();
  }
}