class Trail {
  final String defaultStyle;
  final String geojsonFile;
  final String uuid;
  final String title;
  final List<List<num>> elevationData;

  Trail({
    required this.defaultStyle,
    required this.geojsonFile,
    required this.uuid,
    required this.title,
    required this.elevationData,
  });

  factory Trail.fromJson(Map<String, dynamic> json) => Trail(
        defaultStyle: json['default_Style'] as String,
        geojsonFile: json['geojson_file'] as String,
        uuid: json['uuid'] as String,
        title: json['title'] as String,
        elevationData: (json['elevationData'] as List?)?.map((e) => (e as List<dynamic>).cast<num>())
            .toList() ?? [],
      );
}