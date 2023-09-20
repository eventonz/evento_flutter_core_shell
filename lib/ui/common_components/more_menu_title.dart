import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreMenuTitle extends StatelessWidget {
  const MoreMenuTitle({Key? key, required this.item}) : super(key: key);
  final Items item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            item.title!.capitalize!,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
