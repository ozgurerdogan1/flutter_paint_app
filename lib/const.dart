import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cons {
  static alertDialog(BuildContext context,
      {String title = "title",
      String content = "content",
      Function()? onPressedPositive,
      Function()? onPressedNegative,
      String positiveButtonText = "Evet",
      String negativeButtonText = "Hayır"}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                    onPressed: () {
                      onPressedPositive;
                    },
                    child: Text(positiveButtonText)),
                TextButton(
                    onPressed: () {
                      onPressedNegative;
                    },
                    child: Text(negativeButtonText)),
              ],
            ));
  }

  static snackShow(BuildContext context, String message,
          {EdgeInsetsGeometry? margin, Duration duration = const Duration(seconds: 1)}) =>
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          shape: const StadiumBorder(),
          width: 300.w,
          duration: duration,
          content: SelectableText(
            message,
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          margin: margin,
        ));

  static const List<Color> colors = [
    Colors.red,
    Colors.pink,
    Colors.black,
    Colors.white,
    Colors.yellow,
    Colors.teal,
    Colors.purple,
    Colors.blue,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.brown,
    Colors.cyan,
    Colors.deepOrange
  ];
}
