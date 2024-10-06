import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/athlete_tab_details.dart';
import 'package:evento_core/core/models/detail_item.dart';
import 'package:evento_core/core/models/split_data.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
          return AppColors.white;
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
      {Key? key, required this.data, required this.segments, required this.columns})
      : super(key: key);
  final List<SegmentedSplitData> data;
  final List<SegmentedSplitSegments> segments;
  final List<String> columns;

  @override
  State<SegmentedSplitDataContent> createState() => _SegmentedSplitDataContentState();
}

class _SegmentedSplitDataContentState extends State<SegmentedSplitDataContent> with SingleTickerProviderStateMixin {

  final PageController _controllerHeader = PageController();
  final PageController _controller = PageController();

  double _currentPageHeight = 0;
  int _currentPage = 0;

  // List of GlobalKeys to measure the height of each page
  GlobalKey _pageKey = GlobalKey();

  contentWeight(String style, bool isText) {

    if(style.contains('*bold*')) {
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
          return AppColors.white;
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
  void initState() {
    super.initState();
    // Calculate the height of the first page after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateHeight(0);
    });

    // Listen for page changes to update the height dynamically
    _controller.addListener(() {
      int currentPage = _controller.page?.round() ?? 0;
      _updateHeight(currentPage);
    });
  }

  void _updateHeight(int pageIndex) {
    final context = _pageKey.currentContext;
    print(context);
    print('context');
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      print('height: ${renderBox.size.height}');
      setState(() {
        _currentPageHeight = renderBox.size.height;
      });
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
          Container(
            color: const Color(0xFFF7F7F7),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              children: [
                ...
                  List.generate(widget.segments.length, (index) {
                    return Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPage = index;
                            });
                            _controller.animateToPage(_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            _controllerHeader.animateToPage(_currentPage, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
                            decoration: BoxDecoration(
                              color: _currentPage == index ? Colors.white : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(widget.segments[index].name ?? '', style: TextStyle(
                                fontSize: 17,
                              ),),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            color: const Color(0xFFF7F7F7),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Container(
                            padding: const EdgeInsets.all(12),
                            //color: contentColor(style, false),
                            child: Center(
                              child: AppText(
                                widget.columns.first,
                                fontSize: 17,
                                //color: contentColor(widget.data[i].values!.first, true),
                                //fontWeight: contentWeight(widget.data[i].values!.first, true),
                                textAlign: TextAlign.center,
                                //fontStyle: widget.data[i].values!.first.contains('*italic*') ? FontStyle.italic : null,
                              ),
                            ),
                          )
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 40, // Adjust the height dynamically
                    child: PageView.builder(itemBuilder: (_, i) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    for(int x = 0; x < 3; x++)
                                      Expanded(
                                        child: Center(
                                          child: AppText(
                              widget.columns.length > x+(i*3)+1 ? widget.columns[x+(i*3)+1].replaceAll(RegExp(r'\*(\w+)\*'), '') : '',
                                            //color: contentColor(entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '', true),
                                            //fontWeight: contentWeight(entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '', true),
                                            textAlign: TextAlign.center,
                                            fontSize: 17,
                                            //fontStyle: (entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '').contains('*italics*') ? FontStyle.italic : null,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                    }, itemCount: ((widget.columns.length-1)/3).ceil(), controller: _controllerHeader, physics: const NeverScrollableScrollPhysics(),),
                  ),
                ),
              ],
            ),
          ),
          //Divider(height: .5, color: Colors.grey,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  key: _pageKey,
                  child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.data.length,
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        final entry = widget.data[i].values;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          color: i%2 == 1 ? AppColors.greyLighter : null,
                          child: Center(
                            child: AppText(
                              widget.data[i].values!.first.replaceAll(RegExp(r'\*(\w+)\*'), ''),
                              color: contentColor(widget.data[i].values!.first, true),
                              fontWeight: contentWeight(widget.data[i].values!.first, true),
                              textAlign: TextAlign.center,
                              fontSize: 15,
                              fontStyle: widget.data[i].values!.first.contains('*italic*') ? FontStyle.italic : null,
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Expanded(
                flex: 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _currentPageHeight, // Adjust the height dynamically
                  child: PageView.builder(itemBuilder: (_, i) {
                    return Container(
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.data.length,
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                            final entry = widget.data[index].values;
                            print(entry);
                            print(_currentPageHeight);
                            print(((widget.columns.length-1)/3).ceil());
                            return Container(
                              color: index%2 == 1 ? AppColors.greyLighter : null,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  for (int x = 0; x < 3; x++)
                                    //if(entry!.length > (x+(i*3)+1))
                                    Expanded(
                                      child: Center(
                                        child: AppText(
                                          entry!.length > (x+(i*3)+1) ? entry[(x+(i*3))+1].replaceAll(RegExp(r'\*(\w+)\*'), '') : '',
                                          color: contentColor(entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '', true),
                                          fontWeight: contentWeight(entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '', true),
                                          textAlign: TextAlign.center,
                                          fontSize: 15,
                                          fontStyle: (entry.length > (x+(i*3)+1) ? entry[(x+(i*3))+1] : '').contains('*italics*') ? FontStyle.italic : null,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                    );
                  }, itemCount: ((widget.columns.length-1)/3).ceil(), controller: _controller, physics: const NeverScrollableScrollPhysics()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class SegmentedSplitNewDataContent2 extends StatelessWidget {
  const SegmentedSplitNewDataContent2(
      {Key? key, required this.data, required this.segments, required this.columns})
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
          return AppColors.white;
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
                            data[i].values!.first.replaceAll(RegExp(r'\*(\w+)\*'), ''),
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
                child: PageView.builder(itemBuilder: (_, index) {
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
                                      fontWeight: contentWeight(style, true),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      });
                }, itemCount: (columns.length-1/3).toInt()),
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
  const ExternalLinkContent({super.key, required this.link});

  @override
  Widget build(BuildContext context) {

    bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return ListView.builder(itemBuilder: (_, index) {
      link[index].icon = 'map';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          tileColor: isLightMode ? AppColors.white.withOpacity(0.20) : Color(0xFFF7F7F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: SvgPicture.asset(AppHelper.getSvg('${link[index].icon}'),
          color: isLightMode ? AppColors.white.withOpacity(0.50) : AppColors.darkgrey,),
          title: Text('${link[index].label}', style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),),
          trailing: Icon(Icons.chevron_right),
        ),
      );
    }, physics: const NeverScrollableScrollPhysics(), itemCount: link.length, shrinkWrap: true, padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 32));
  }
}

class PaceDataContent extends StatelessWidget {

  final List<PaceData> data;
  const PaceDataContent({super.key, required this.data});

  

  @override
  Widget build(BuildContext context) {

     bool isLightMode = Theme.of(context).brightness == Brightness.light;
    return ListView.builder(itemBuilder: (_, index) {
      print((MediaQuery.of(context).size.width));
      print(((MediaQuery.of(context).size.width/2)+(((MediaQuery.of(context).size.width/2)/100)*data[index].value!))-36);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: ((MediaQuery.of(context).size.width/2)+(((MediaQuery.of(context).size.width/2)/100)*data[index].value!))-36,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isLightMode ? AppColors.white.withOpacity(0.20) : Color(0xFFF7F7F7),
              ),
              child: Row(
                children: [
                  if(data[index].icon != null)
                    ...[
                      SvgPicture.asset(AppHelper.getSvg(data[index].icon!), height: 23,),
                      const SizedBox(width: 5),
                    ],
                  Text(data[index].range!.split('-')[0], style: TextStyle(
                    fontSize: 18,
                  ),),
                  const SizedBox(width: 5),
                  Icon(CupertinoIcons.arrow_right, size: 20),
                  const SizedBox(width: 5),
                  Text(data[index].range!.split('-')[1], style: TextStyle(
                    fontSize: 18,
                  ),),
                  const SizedBox(width: 12),
                  Text(data[index].time ?? '', style: TextStyle(
                    fontSize: 18,
                  ),),
                ],
              ),
            ),
          ],
        ),
      );
    },
    physics: const NeverScrollableScrollPhysics(), itemCount: data.length, shrinkWrap: true, padding: const EdgeInsets.only(left: 18, right: 18, top: 0, bottom: 32));
  }
}


class SplitTitleContent extends StatelessWidget {

  final TitleData title;
  const SplitTitleContent({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Text(title.label!, style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),),
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
  const SplitDetailsHeader2({Key? key, required this.details}) : super(key: key);
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
  const SplitDataContent2({Key? key, required this.items, this.showSplit = true})
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
