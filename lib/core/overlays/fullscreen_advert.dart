import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/advert.dart';
import '../utils/api_handler.dart';
import '../utils/app_global.dart';
import '../utils/helpers.dart';
import '../utils/keys.dart';
import '../utils/preferences.dart';

class FullscreenAdvert extends StatefulWidget {

  final Advert advert;
  const FullscreenAdvert(this.advert, {super.key});

  @override
  State<FullscreenAdvert> createState() => _FullscreenAdvertState();
}

class _FullscreenAdvertState extends State<FullscreenAdvert> {

  int seconds = 5;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    trackEvent('impression');
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds--;
      });
      if(seconds == 0) {
        timer.cancel();
        Navigator.of(context).pop();
      }
    });
  }

  trackEvent(String action) async {
    String url = 'adverts/${widget.advert.id}';
    final res = await ApiHandler.postHttp(
        
        endPoint: url, body: {
          'action' : action,
    });
    print(res.data);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
                onTap: () {
                  trackEvent('click');
                  launchUrl(Uri.parse(widget.advert.openUrl!), mode: LaunchMode.externalApplication);
                },
                child: Image(image: CachedNetworkImageProvider(widget.advert.image!), fit: BoxFit.fitWidth, width: double.maxFinite)),
          ),
          Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), curve: Curves.easeIn,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: seconds < 8 ? Colors.white : null,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                            padding: seconds < 8 ? const EdgeInsets.only(left: 6, right: 6) : null,
                            duration: const Duration(milliseconds: 300), curve: Curves.easeIn, child: seconds < 8 ? Text('Auto close in $seconds', style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black
                            )) : null),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: seconds < 8 ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4), spreadRadius: seconds < 8 ? 0 : 1, blurRadius: 3),
                            ],
                          ),
                          child: const Icon(Icons.close, size: 19,
                          color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
