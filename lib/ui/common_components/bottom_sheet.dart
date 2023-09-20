import 'package:evento_core/core/res/app_colors.dart';
import 'package:flutter/material.dart';

class AppFixedBottomSheet {
  final BuildContext context;
  final bool enableDrag;

  AppFixedBottomSheet(this.context, {this.enableDrag = false});

  Future<void> show({required Widget child}) async {
    await showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.transparent,
        isScrollControlled: true,
        enableDrag: enableDrag,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 60),
        builder: (_) => child);
  }
}
