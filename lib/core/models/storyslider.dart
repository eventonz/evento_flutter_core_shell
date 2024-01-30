import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:video_player/video_player.dart';

class StorySlider {
  String? openUrl;
  String? image;
  String? video;
  String? type;
  Rx<VideoPlayerController>? videoPlayerController;

  StorySlider({this.openUrl, this.image, this.video, this.type, this.videoPlayerController});

  StorySlider.fromJson(Map<String, dynamic> json) {
    openUrl = json['open_url'];
    image = json['image'];
    video = json['video'];
    print(video);
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open_url'] = openUrl;
    data['image'] = image;
    data['video'] = video;
    data['type'] = type;
    return data;
  }
}