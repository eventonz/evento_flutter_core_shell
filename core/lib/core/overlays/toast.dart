import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static Future<void> show(String? message,
      {bool lengthShort = true, int timeInSecForIosWeb = 2}) async {
    Fluttertoast.showToast(
        msg: message ?? 'Something went wrong. Try again later',
        toastLength: lengthShort ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
        timeInSecForIosWeb: timeInSecForIosWeb,
        fontSize: 16.0);
  }
}
