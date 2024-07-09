import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/common_components/no_data_found_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventTile extends StatelessWidget {
  const EventTile({Key? key, required this.onTap, required this.event})
      : super(key: key);
  final VoidCallback onTap;
  final Event event;

  Widget _buildTile() {
    if (event.size == "small") {
      return _buildSmallTile();
    }
    return _buildLargeTile();
  }

  Widget _buildSmallTile() {
    return Row(
      children: [
        event.smallImage != null && event.smallImage!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: event.smallImage!,
                  placeholder: (_, val) =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  errorWidget: (_, val, val2) => const Center(
                      child: NoDataFoundLayout(
                    errorMessage: 'No Image Found',
                  )),
                  width: 36.w,
                  height: 8.h,
                  fit: BoxFit.cover,
                ),
              )
            : const SizedBox(),
        SizedBox(
          width: 4.w,
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                event.title,
                fontWeight: FontWeight.bold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 1,
              ),
              AppText(
                event.subtitle,
                color: AppColors.grey,
                fontSize: 12,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLargeTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        event.largeImage != null && event.largeImage!.isNotEmpty
            ? SizedBox(
                height: 24.h,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: event.largeImage!,
                        placeholder: (_, val) => const Center(
                            child: CircularProgressIndicator.adaptive()),
                        errorWidget: (_, val, val2) => const Center(
                            child: NoDataFoundLayout(
                          errorMessage: 'No Image Found',
                        )),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    event.tag != null
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: AppHelper.hexToColor(event.tag!.color),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      BlinkingLiveIcon(
                                        isBlinking: event.tag!.blinking,
                                      ),
                                      SizedBox(
                                        width: 1.4.w,
                                      ),
                                      AppText(
                                        event.tag!.text,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
              )
            : const SizedBox(),
        SizedBox(
          height: 1.h,
        ),
        AppText(
          event.title,
          fontWeight: FontWeight.bold,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          height: 2,
        ),
        AppText(
          event.subtitle,
          color: AppColors.grey,
          fontSize: 12,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque, onTap: onTap, child: _buildTile());
  }
}

class BlinkingLiveIcon extends StatefulWidget {
  const BlinkingLiveIcon({super.key, required this.isBlinking});
  final bool isBlinking;

  @override
  State<BlinkingLiveIcon> createState() => _BlinkingLiveIconState();
}

class _BlinkingLiveIconState extends State<BlinkingLiveIcon> {
  late bool _blinking = true;
  bool _isVisible = true;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _blinking = widget.isBlinking;
    _startBlinking();
  }

  void _startBlinking() {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
    });
  }

  Widget liveIcon() {
    return Icon(
      Icons.fiber_manual_record,
      size: 4.w,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _blinking
        ? AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: liveIcon())
        : liveIcon();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}
