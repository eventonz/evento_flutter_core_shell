import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/athlete_tab_details.dart';
import 'package:evento_core/core/models/detail_item.dart';
import 'package:evento_core/core/models/split_data.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'text.dart';

class SplitNewDataContent2 extends StatelessWidget {
  const SplitNewDataContent2(
      {Key? key, required this.splitDataList, this.showSplit = true})
      : super(key: key);
  final List<Splits> splitDataList;
  final bool showSplit;

  contentWeight(String style, bool isText) {
    switch (style) {
      case 'split_bold':
        return FontWeight.w700;

      default:
        return FontWeight.w500;
    }
  }

  Color contentColor(String style, bool isText) {
    if (style.contains('*red*')) {
      return AppColors.red;
    }

    if (style.contains('*green*')) {
      return AppColors.splitGreen;
    }

    if (style.contains('*black*')) {
      return AppColors.black;
    }

    if (!isText) {
      switch (style) {
        case 'split_black':
          return AppColors.splitBlack;
        case 'split_green':
          return AppColors.splitGreen;
        case 'split_orange':
          return AppColors.splitOrange;
        case 'split_grey':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.darkgrey
              : AppColors.splitGrey;
        case 'split_blue':
          return AppColors.splitBlue;
        case 'split_lightblue':
          return AppColors.splitLightBlue;
        case 'split_lightgrey':
          return AppColors.splitLightGrey;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'estimate':
          return AppColors.header;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.transparent
              : AppColors.white;
      }
    } else {
      switch (style) {
        case 'split_black':
        case 'split_green':
        case 'split_orange':
        case 'split_grey':
        case 'split_blue':
        case 'split_lightblue':
          return AppColors.white;
        case 'split_lightgrey':
          return AppColors.black;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'estimate':
          return AppColors.estimateText;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.white
              : AppColors.black.withOpacity(0.75);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: showSplit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AppText(
                AppLocalizations.of(context)!.splits,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 0),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: splitDataList.length,
              shrinkWrap: true,
              itemBuilder: (_, i) {
                final entry = splitDataList[i].data;
                final style = splitDataList[i].style ?? '';
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: contentColor(style, false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (String content in entry ?? [])
                        Flexible(
                          child: Center(
                            child: AppText(
                              content,
                              color: contentColor(style, true),
                              fontWeight: contentWeight(style, true),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class SegmentedSplitDataContent extends StatefulWidget {
  const SegmentedSplitDataContent(
      {Key? key,
      required this.data,
      required this.segments,
      required this.columns})
      : super(key: key);
  final List<SegmentedSplitData> data;
  final List<SegmentedSplitSegments> segments;
  final List<String> columns;

  @override
  State<SegmentedSplitDataContent> createState() =>
      _SegmentedSplitDataContentState();
}

class _SegmentedSplitDataContentState extends State<SegmentedSplitDataContent>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;

  contentWeight(String style, bool isText) {
    if (style.contains('*bold*')) {
      return FontWeight.w700;
    }

    switch (style) {
      case 'split_bold':
        return FontWeight.w700;
      default:
        return FontWeight.w400;
    }
  }

  Color contentColor(String style, bool isText) {
    if (style.contains('*red*')) {
      return AppColors.red;
    }

    if (style.contains('*green*')) {
      return AppColors.splitGreen;
    }

    if (style.contains('*black*')) {
      return AppColors.black;
    }

    if (!isText) {
      switch (style) {
        case 'split_black':
          return AppColors.splitBlack;
        case 'split_green':
          return AppColors.splitGreen;
        case 'split_orange':
          return AppColors.splitOrange;
        case 'split_grey':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.darkgrey
              : AppColors.splitGrey;
        case 'split_blue':
          return AppColors.splitBlue;
        case 'split_lightblue':
          return AppColors.splitLightBlue;
        case 'split_lightgrey':
          return AppColors.splitLightGrey;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'estimate':
          return AppColors.header;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.transparent
              : AppColors.white;
      }
    } else {
      switch (style) {
        case 'split_black':
        case 'split_green':
        case 'split_orange':
        case 'split_grey':
        case 'split_blue':
        case 'split_lightblue':
          return AppColors.white;
        case 'split_lightgrey':
          return AppColors.black;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'estimate':
          return AppColors.estimateText;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.white
              : AppColors.black.withOpacity(0.75);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Container(
            color: Theme.of(Get.context!).brightness != Brightness.light
                ? const Color(0xFFF7F7F7)
                : AppColors.splitGrey,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                ...List.generate(widget.segments.length, (index) {
                  return Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 3),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Theme.of(Get.context!).brightness !=
                                        Brightness.light
                                    ? Colors.white.withOpacity(1)
                                    : Colors.white.withOpacity(0.3)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _currentPage == index
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              widget.segments[index].name ?? '',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: Theme.of(Get.context!).brightness != Brightness.light
                ? const Color(0xFFF7F7F7)
                : AppColors.splitGrey,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: AppText(
                        widget.columns.first,
                        fontSize: 14,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        for (int x = 0;
                            x < widget.segments[_currentPage].columns!.length;
                            x++)
                          Expanded(
                            child: Center(
                              child: AppText(
                                widget.segments[_currentPage].columns![x]
                                    .replaceAll(RegExp(r'\*(\w+)\*'), ''),
                                textAlign: TextAlign.center,
                                fontSize: 14,
                                maxLines: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: _splitList(widget.data).map((segment) {
                    int segmentLength =
                        segment is _StaticRow ? 1 : segment.rows.length;
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: segmentLength,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        final currentIndex = segment is _StaticRow
                            ? segment.row.index!
                            : segment.rows[i].index!;
                        final entry = widget.data[currentIndex].values;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          color: widget.data[currentIndex].style != null
                              ? contentColor(
                                  widget.data[currentIndex].style!, false)
                              : (currentIndex % 2 == 1
                                  ? (Theme.of(Get.context!).brightness ==
                                          Brightness.light
                                      ? AppColors.darkgrey
                                      : AppColors.greyLighter)
                                  : null),
                          child: Center(
                            child: SizedBox(
                              height: 21,
                              child: AppText(
                                entry!.first
                                    .replaceAll(RegExp(r'\*(\w+)\*'), ''),
                                color: segment is _StaticRow
                                    ? Colors.white
                                    : contentColor(entry.first, true),
                                fontWeight: contentWeight(entry.first, true),
                                textAlign: TextAlign.center,
                                fontSize: 15,
                                fontStyle: entry.first.contains('*italic*')
                                    ? FontStyle.italic
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _splitList(widget.data).map((segment) {
                    if (segment is _StaticRow) {
                      return Container(
                        color: segment.row.style != null
                            ? contentColor(segment.row.style!, false)
                            : (segment.row.index! % 2 == 1
                                ? (Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.darkgrey
                                    : AppColors.greyLighter)
                                : null),
                        padding: const EdgeInsets.all(14),
                        child: widget.segments.first.columns!.length == 1
                            ? const SizedBox(height: 21)
                            : Row(
                                children: List.generate(
                                  segment.row.values!.length - 1,
                                  (x) => Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        height: 21,
                                        child: AppText(
                                          segment.row.values![x + 1],
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: segment.rows.length,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          final row = segment.rows[index];
                          final style = row.style;
                          final entry = row.values;
                          final columns =
                              widget.segments[_currentPage].columns!;

                          List<Widget> widgets = [];
                          if (entry?.length == 1 && row.point == 'static') {
                            for (int x = 0; x < columns.length; x++) {
                              widgets.add(const Expanded(
                                child: Center(
                                  child:
                                      SizedBox(height: 21, child: AppText('')),
                                ),
                              ));
                            }
                          }

                          for (int x = row.point == 'static' ? 1 : 0;
                              x <
                                  (row.point == 'static'
                                      ? entry!.length
                                      : columns.length);
                              x++) {
                            widgets.add(Expanded(
                              child: Center(
                                child: SizedBox(
                                  height: 21,
                                  child: AppText(
                                    entry!.length > x
                                        ? entry[x].replaceAll(
                                            RegExp(r'\*(\w+)\*'), '')
                                        : '',
                                    color: contentColor(entry[x], true),
                                    fontWeight: contentWeight(entry[x], true),
                                    textAlign: TextAlign.center,
                                    fontSize: 15,
                                    fontStyle: entry[x].contains('*italic*')
                                        ? FontStyle.italic
                                        : null,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ));
                          }

                          return Container(
                            color: style != null
                                ? contentColor(style, false)
                                : (segment.rows[index].index! % 2 == 1
                                    ? (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.darkgrey
                                        : AppColors.greyLighter)
                                    : null),
                            padding: const EdgeInsets.all(14),
                            child: Row(children: widgets),
                          );
                        },
                      );
                    }
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<dynamic> _splitList(List<SegmentedSplitData> data) {
  List<dynamic> result = [];
  int index = 0;
  List<SegmentedSplitData> tempNormalRows = [];

  for (var item in data) {
    item.index = index;
    if (item.point == 'static') {
      // Push the previous normal row group first
      if (tempNormalRows.isNotEmpty) {
        // tempNormalRows.add(SegmentedSplitData.fromJson({
        //   'values' : tempNormalRows.last.values!.map((e) => '').toList(),
        // }));
        result.add(_NormalRowsGroup(tempNormalRows));
        tempNormalRows = [];
      }
      // Add static row separately
      result.add(_StaticRow(item));
    } else {
      tempNormalRows.add(item);
    }
    index++;
  }

  // Add remaining normal rows if any
  if (tempNormalRows.isNotEmpty) {
    result.add(_NormalRowsGroup(tempNormalRows));
  }

  return result;
}

class _StaticRow {
  final SegmentedSplitData row;
  _StaticRow(this.row);
}

class _NormalRowsGroup {
  final List<SegmentedSplitData> rows;
  _NormalRowsGroup(this.rows);
}

class SegmentedSplitNewDataContent2 extends StatelessWidget {
  const SegmentedSplitNewDataContent2(
      {Key? key,
      required this.data,
      required this.segments,
      required this.columns})
      : super(key: key);
  final List<SegmentedSplitData> data;
  final List<SegmentedSplitSegments> segments;
  final List<String> columns;

  contentWeight(String style, bool isText) {
    switch (style) {
      case 'split_bold':
        return FontWeight.w700;

      default:
        return FontWeight.w500;
    }
  }

  Color contentColor(String style, bool isText) {
    if (!isText) {
      switch (style) {
        case 'split_black':
          return AppColors.splitBlack;
        case 'split_green':
          return AppColors.splitGreen;
        case 'split_orange':
          return AppColors.splitOrange;
        case 'split_grey':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.darkgrey
              : AppColors.splitGrey;
        case 'split_blue':
          return AppColors.splitBlue;
        case 'split_lightblue':
          return AppColors.splitLightBlue;
        case 'split_lightgrey':
          return AppColors.splitLightGrey;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.grey
              : AppColors.header;
        case 'estimate':
          return AppColors.header;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.transparent
              : AppColors.white;
      }
    } else {
      switch (style) {
        case 'split_black':
        case 'split_green':
        case 'split_orange':
        case 'split_grey':
        case 'split_blue':
        case 'split_lightblue':
          return AppColors.white;
        case 'split_lightgrey':
          return AppColors.black;
        case 'separator':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'header':
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.headerText;
        case 'estimate':
          return AppColors.estimateText;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.white
              : AppColors.black;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 2,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    shrinkWrap: true,
                    itemBuilder: (_, i) {
                      final entry = data[i].values;
                      final style = data[i].point ?? '';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        //color: contentColor(style, false),
                        child: Center(
                          child: AppText(
                            data[i]
                                .values!
                                .first
                                .replaceAll(RegExp(r'\*(\w+)\*'), ''),
                            //color: contentColor(style, true),
                            //fontWeight: contentWeight(style, true),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
              ),
              Expanded(
                flex: 5,
                child: PageView.builder(
                    itemBuilder: (_, index) {
                      return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          shrinkWrap: true,
                          itemBuilder: (_, i) {
                            final entry = data[i].values;
                            final style = data[i].point ?? '';
                            return Container(
                              height: 20,
                              padding: const EdgeInsets.all(16),
                              color: contentColor(style, false),
                              child: Row(
                                children: [
                                  for (String content in entry ?? [])
                                    Expanded(
                                      child: Center(
                                        child: AppText(
                                          content,
                                          color: contentColor(style, true),
                                          fontWeight:
                                              contentWeight(style, true),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          });
                    },
                    itemCount: (columns.length - 1 / 3).toInt()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExternalLinkContent extends StatelessWidget {
  final List<ExternalLinkData> link;
  final String disRaceNo;
  const ExternalLinkContent(
      {super.key, required this.link, required this.disRaceNo});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (_, index) {
          print(Theme.of(Get.context!).brightness);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              onTap: () {
                launchUrl(Uri.parse(
                    link[index].url!.replaceAll('{{RaceNo}}', disRaceNo)));
              },
              tileColor: Theme.of(Get.context!).brightness != Brightness.light
                  ? const Color(0xFFF7F7F7)
                  : AppColors.darkgrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: link[index].icon != null
                  ? SvgPicture.asset(
                      AppHelper.getSvg('${link[index].icon}'),
                      height: 23,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black, // Color for light mode
                        BlendMode.srcIn,
                      ),
                    )
                  : null,
              title: Text(
                '${link[index].label}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        itemCount: link.length,
        shrinkWrap: true,
        padding:
            const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 32));
  }
}

class PaceDataContent extends StatelessWidget {
  final List<PaceData> data;
  const PaceDataContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (_, index) {
          print((MediaQuery.of(context).size.width));
          print(((MediaQuery.of(context).size.width / 2) +
                  (((MediaQuery.of(context).size.width / 2) / 100) *
                      data[index].value!)) -
              36);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: ((MediaQuery.of(context).size.width / 2) +
                          (((MediaQuery.of(context).size.width / 2) / 100) *
                              data[index].value!)) -
                      36,
                  height: 39,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).brightness != Brightness.light
                        ? const Color(0xFFF7F7F7)
                        : Colors.white.withOpacity(0.14),
                  ),
                  child: Row(
                    children: [
                      if (data[index].icon != null) ...[
                        SvgPicture.asset(
                          AppHelper.getSvg(data[index].icon!),
                          height: 23,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white.withOpacity(0.7)
                                : Colors.black, // Color for light mode
                            // Color for dark mode
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(
                            width:
                                12), // Move this outside the SvgPicture widget
                      ],
                      Text(
                        data[index].range!,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        data[index].time ?? '',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        shrinkWrap: true,
        padding:
            const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 32));
  }
}

class SplitTitleContent extends StatelessWidget {
  final TitleData title;
  const SplitTitleContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Text(
        title.label!,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SummaryDataContent2 extends StatelessWidget {
  const SummaryDataContent2({super.key, this.summary});
  final SummaryData? summary;

  Widget _buildSummaryView() {
    return summary == null ? _buildEmptyView() : _buildSummaryDataView();
  }

  Widget _buildEmptyView() {
    return const SizedBox();
  }

  Widget _buildSummaryDataView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTopInfoView(summary!.top),
          //_buildSummaryListView(summary!.list ?? []),
        ],
      ),
    );
  }

  Widget _buildTopInfoView(SummaryDataTop? top) {
    if (top == null) {
      return _buildEmptyView();
    }
    return Column(
      children: [
        SizedBox(
          height: 18.h,
          child: Stack(
            children: [
              if (top.medal != null)
                Positioned(
                  right: 10,
                  child: CachedNetworkImage(
                    imageUrl: top.medal!,
                    placeholder: (_, val) => const Center(
                        child: CircularProgressIndicator.adaptive()),
                    errorWidget: (_, val, val2) => const Center(
                        child: Center(child: Icon(FeatherIcons.alertTriangle))),
                    fit: BoxFit.cover,
                    height: 14.h,
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (top.result != null) ...[
                      AppText(
                        top.result!,
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                    ],
                    if (top.subtitle != null)
                      AppText(
                        top.subtitle!,
                        fontSize: 17,
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        //const Divider(height: 1, thickness: .5, color: AppColors.greyLight),
        if (top.infoBar.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (SummaryDataTopInfoBar info in top.infoBar)
                  Column(
                    children: [
                      AppText(
                        info.value,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      AppText(
                        info.name,
                        fontSize: 15,
                      ),
                    ],
                  )
              ],
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ],
    );
  }

  Widget _buildSummaryListView(List<DataList> dataList) {
    if (dataList.isEmpty) {
      return _buildEmptyView();
    }
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dataList.length,
        separatorBuilder: (_, i) {
          return const Divider(
              height: 1, thickness: .5, color: AppColors.greyLight);
        },
        itemBuilder: (_, i) {
          final split = dataList[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                if (split.icon != null)
                  AppText(
                    split.icon!,
                  ),
                if (split.name != null)
                  AppText(
                    split.name!,
                    fontWeight: FontWeight.bold,
                  ),
                if (split.value != null) ...[
                  const Spacer(),
                  AppText(
                    split.value!,
                    fontWeight: FontWeight.bold,
                  )
                ]
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildSummaryView();
  }
}

class SplitTableBuild2 extends StatelessWidget {
  const SplitTableBuild2({Key? key, required this.splitData}) : super(key: key);
  final SplitDataM splitData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SplitDetailsHeader2(details: splitData.itemsWrapper!.first),
        SplitDataContent2(items: splitData.itemsWrapper!),
      ],
    );
  }
}

class SplitDetailsHeader2 extends StatelessWidget {
  const SplitDetailsHeader2({Key? key, required this.details})
      : super(key: key);
  final ItemsWrapper details;

  Widget createSplitTimings() {
    if (details.items == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (Items item in details.items!)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  item.value ?? '',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(
                  height: 6,
                ),
                AppText(
                  item.name ?? '',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w200,
                )
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return details.result == null
        ? const SizedBox()
        : Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              AppText(
                details.result ?? '',
                fontSize: 24.sp,
                fontWeight: FontWeight.w300,
              ),
              const SizedBox(
                height: 10,
              ),
              createSplitTimings()
            ],
          );
  }
}

class SplitDataContent2 extends StatelessWidget {
  const SplitDataContent2(
      {Key? key, required this.items, this.showSplit = true})
      : super(key: key);
  final List<ItemsWrapper> items;
  final bool showSplit;

  Color contentColor(String style, bool isText) {
    if (!isText) {
      switch (style) {
        case 'split_black':
          return AppColors.splitBlack;
        case 'split_green':
          return AppColors.splitGreen;
        case 'split_orange':
          return AppColors.splitOrange;
        case 'split_grey':
          return AppColors.splitGrey;
        case 'separator':
          return AppColors.separator;
        case 'header':
          return AppColors.header;
        case 'estimate':
          return AppColors.header;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.transparent
              : AppColors.white;
      }
    } else {
      switch (style) {
        case 'split_black':
        case 'split_green':
        case 'split_orange':
        case 'split_grey':
          return AppColors.white;
        case 'separator':
          return AppColors.separatorText;
        case 'header':
          return AppColors.headerText;
        case 'estimate':
          return AppColors.estimateText;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.white
              : AppColors.black;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final splitDataContent = items.firstWhereOrNull((x) => x.type == 'splits');
    if (splitDataContent == null) {
      return const Center(
        child: NoDataFoundLayout(
          title: 'No details found',
          errorMessage: '',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: showSplit,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppText(
              'Splits',
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splitDataContent.entries!.length,
            shrinkWrap: true,
            itemBuilder: (_, i) {
              final entry = splitDataContent.entries![i];
              final style = entry.style ?? '';
              return Container(
                padding: const EdgeInsets.all(16),
                color: contentColor(style, false),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (String content in entry.data!)
                      Flexible(
                        child: Center(
                          child: AppText(
                            content,
                            color: contentColor(style, true),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
      ],
    );
  }
}
