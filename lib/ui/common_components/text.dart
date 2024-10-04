import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(this.text,
      {Key? key,
      this.color,
      this.fontSize,
      this.fontWeight,
      this.fontStyle,
      this.fontFamily,
      this.textAlign,
      this.style,
      this.maxLines,
      this.overflow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      overflow: overflow,
      maxLines: maxLines,
      style: style ??
          TextStyle(
              overflow: overflow,
              fontFamily: fontFamily,
              fontWeight: fontWeight,
              fontSize: fontSize,
              fontStyle: fontStyle,
              color: color),
    );
  }
}
