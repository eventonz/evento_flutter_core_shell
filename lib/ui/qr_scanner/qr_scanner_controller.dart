import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // Barcode? result;
  late double scanArea;
  late String url;
  // late MobileScannerController mobileScannerController;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    url = res[AppKeys.url];
    setupMobileAScannerController();
  }

  void setupMobileAScannerController() {
    // mobileScannerController =
    // MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  }

  // void onDetect(BarcodeCapture capture) {
  //   final List<Barcode> barcodes = capture.barcodes;
  //   late Barcode barcode;
  //   for (final code in barcodes) {
  //     barcode = code;
  //   }
  //   if (barcode.rawValue == null) {
  //     ToastUtils.show('Failed to scan QR code');
  //   } else {
  //     Get.back(result: {AppKeys.qrData: barcode.rawValue!});
  //   }
  //   update();
  // }
}
