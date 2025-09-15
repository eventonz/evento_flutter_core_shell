import 'dart:async';
import 'package:evento_core/core/models/detail_item.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';

class LiveTimingCard extends StatefulWidget {
  final LiveTimingData liveData;

  const LiveTimingCard({super.key, required this.liveData});

  @override
  State<LiveTimingCard> createState() => _LiveTimingCardState();
}

class _LiveTimingCardState extends State<LiveTimingCard> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    if (widget.liveData.racetime == null || widget.liveData.racetime!.isEmpty) {
      return;
    }

    // Parse the initial time from the API response
    final timeParts = widget.liveData.racetime!.split(':');
    if (timeParts.length == 3) {
      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      final seconds = int.tryParse(timeParts[2]) ?? 0;

      // Set the initial elapsed time from the API response
      _elapsedTime = Duration(hours: hours, minutes: minutes, seconds: seconds);

      // Only start counting up if the time is not 00:00:00
      if (hours > 0 || minutes > 0 || seconds > 0) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = Duration(seconds: _elapsedTime.inSeconds + 1);
      });
    });
  }

  String _formatHours(Duration duration) {
    return duration.inHours.toString().padLeft(2, '0');
  }

  String _formatMinutes(Duration duration) {
    return duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  }

  String _formatSeconds(Duration duration) {
    return duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (widget.liveData.label != null &&
              widget.liveData.label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppText(
                widget.liveData.label!,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLightMode ? AppColors.black : AppColors.white,
              ),
            ),

          // Live Clock
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live indicator dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? (isLightMode
                            ? AppColors.accentDark
                            : AppColors.accentLight)
                        : AppColors.greyLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Time display - separate widgets to prevent movement
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hours
                    SizedBox(
                      width: 80,
                      child: Text(
                        _formatHours(_elapsedTime),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:
                              isLightMode ? AppColors.black : AppColors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Colon
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? AppColors.black : AppColors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    // Minutes
                    SizedBox(
                      width: 80,
                      child: Text(
                        _formatMinutes(_elapsedTime),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:
                              isLightMode ? AppColors.black : AppColors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Colon
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? AppColors.black : AppColors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    // Seconds
                    SizedBox(
                      width: 80,
                      child: Text(
                        _formatSeconds(_elapsedTime),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:
                              isLightMode ? AppColors.black : AppColors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
