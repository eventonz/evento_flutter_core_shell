class MiniPlayerConfig {
  String? id;
  String? ytUrl;
  bool? isLiveStream;
  String? title;

  MiniPlayerConfig({this.id, this.ytUrl, this.isLiveStream, this.title});

  MiniPlayerConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    ytUrl = json['yt_url'];
    isLiveStream = json['is_live_stream'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['yt_url'] = ytUrl;
    data['is_live_stream'] = isLiveStream.toString();
    return data;
  }
}