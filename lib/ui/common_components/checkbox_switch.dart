import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppCheckBox extends StatelessWidget {
  const AppCheckBox({Key? key, required this.isChecked}) : super(key: key);
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Platform.isAndroid
          ? Checkbox(
              onChanged: null,
              value: isChecked,
            )
          : CupertinoSwitch(
              onChanged: null,
              value: isChecked,
            ),
    );
  }
}
