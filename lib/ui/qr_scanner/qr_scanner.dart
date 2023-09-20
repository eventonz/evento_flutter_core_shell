import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_scanner_controller.dart';
import 'qr_shape_overlay.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QRScannerController());
    controller.scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Scan QR',
          style: AppStyles.appBarTitle,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                        controller: controller.mobileScannerController,
                        onDetect: (capture) => controller.onDetect(capture)),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: QrScannerOverlayShape(
                              borderRadius: 10,
                              borderColor: AppColors.primary,
                              borderLength: 8,
                              borderWidth: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
