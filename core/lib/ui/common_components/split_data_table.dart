import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/athlete_tab_details.dart';
import 'package:evento_core/core/models/split_data.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'text.dart';

class SplitNewDataContent extends StatelessWidget {
  const SplitNewDataContent(
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
              ? AppColors.greyLight
              : AppColors.header;
        case 'estimate':
          return AppColors.header;
        default:
          return Theme.of(Get.context!).brightness == Brightness.light
              ? AppColors.white
              : AppColors.transparent;
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
              ? AppColors.black
              : AppColors.white;
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

class SummaryDataContent extends StatelessWidget {
  const SummaryDataContent({super.key, this.summary});
  final Summary? summary;

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
          _buildSummaryListView(summary!.list ?? []),
        ],
      ),
    );
  }

  Widget _buildTopInfoView(Top? top) {
    if (top == null) {
      return _buildEmptyView();
    }
    return Column(
      children: [
        SizedBox(
          height: 16.h,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                    ],
                    if (top.subtitle != null)
                      AppText(
                        top.subtitle!,
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
        const Divider(height: 1, thickness: .5, color: AppColors.greyLight),
        if (top.infoBar.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (InfoBar info in top.infoBar)
                  Column(
                    children: [
                      AppText(
                        info.value,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      AppText(
                        info.name,
                        fontSize: 12,
                      ),
                    ],
                  )
              ],
            ),
          )
        ],
        const Divider(height: 1, thickness: .5, color: AppColors.greyLight),
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

class SplitTableBuild extends StatelessWidget {
  const SplitTableBuild({Key? key, required this.splitData}) : super(key: key);
  final SplitDataM splitData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SplitDetailsHeader(details: splitData.itemsWrapper!.first),
        SplitDataContent(items: splitData.itemsWrapper!),
      ],
    );
  }
}

class SplitDetailsHeader extends StatelessWidget {
  const SplitDetailsHeader({Key? key, required this.details}) : super(key: key);
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

class SplitDataContent extends StatelessWidget {
  const SplitDataContent({Key? key, required this.items, this.showSplit = true})
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
              ? AppColors.white
              : AppColors.transparent;
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
              ? AppColors.black
              : AppColors.white;
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
