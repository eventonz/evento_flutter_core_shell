import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:get/get.dart';

import 'eventomap_controller.dart';

// Main Drawer Widget
class CustomDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;

  const CustomDrawer(this._scaffoldKey, {super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(EventoMapController());

    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CloseButton(_scaffoldKey),
              const SizedBox(height: 16),
              MapStyleSection(),
              const SizedBox(height: 20),
              ToggleSwitchList(
                title: AppLocalizations.of(context)!.elevationProfile,
                value: controller.showElevation,
                onChanged: controller.changeElevation,
              ),
              ToggleSwitchList(
                title: AppLocalizations.of(context)!.distanceMarkers,
                value: controller.showDistanceMarkers,
                onChanged: controller.changeDistanceMarkers,
              ),
              const SizedBox(height: 20),
              PointsOfInterestSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// Close Button Widget
class CloseButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;

  CloseButton(this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.closeEndDrawer();
            },
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Map Style Section Widget
class MapStyleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(EventoMapController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.mapStyle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: controller.mapStyles.length,
            itemBuilder: (_, index) {
              return Obx(
                    () => GestureDetector(
                  onTap: () {
                    controller.changeStyle(index);
                  },
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          border: controller.mapStyle.value == controller.mapStyles[index]
                              ? Border.all(color: Colors.green, width: 3)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(AppHelper.getImage(controller.getStyleImage(controller.mapStyles[index]))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(controller.getStyleName(controller.mapStyles[index])),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Toggle Switch List Widget
class ToggleSwitchList extends StatelessWidget {
  final String title;
  final RxBool value;
  final Function(bool) onChanged;

  const ToggleSwitchList({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => SwitchListTile(
        contentPadding: EdgeInsets.only(right: 16.0),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        value: value.value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}

// Points of Interest Section Widget
class PointsOfInterestSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final controller = Get.put(EventoMapController());

    return Obx(
          () {
        List<GeoJsonFeature<dynamic>> points = [];
        List<String> types = [];

        final list = controller.geoJson.features
            .where((element) => element.type == GeoJsonFeatureType.point);

        list.forEach((element) {
          if (!types.contains(element.properties?['type'] == 'custom' ? element.properties!['icon'] : element.properties?['type'])) {
        
            types.add(element.properties?['type'] == 'custom' ? element.properties!['icon'] : element.properties?['type']);
            points.add(element);
          }
        });

        final selectedInterests = controller.selectedInterests.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.mapStyle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              children: [
                InterestButton(
                  label: 'All',
                  isSelected: selectedInterests.contains(''),
                  onTap: () {
                    if (selectedInterests.contains('')) {
                      controller.updateSelectedInterests([]);
                    } else {
                      controller.updateSelectedInterests(['']);
                    }
                  },
                ),
                ...points.map((e) => InterestButton(
                  label: e.properties?['type'] == 'custom' ? e.properties!['icon'] : controller.iopTypesMap[e.properties?['type']] ?? '',
                  isSelected: selectedInterests.contains(e.properties?['type']),
                  onTap: () {
                    if (controller.selectedInterests.value.contains('')) {
                      controller.updateSelectedInterests([]);
                    }
                    if (controller.selectedInterests.value
                        .contains(e.properties?['type'])) {
                      controller.updateSelectedInterests(
                        List.from(controller.selectedInterests.value)
                          ..remove(e.properties?['type']),
                      );
                    } else {
                      controller.updateSelectedInterests([
                        e.properties?['type'],
                        ...controller.selectedInterests.value
                      ]);
                    }
                  },
                )),
              ],
            ),
          ],
        );
      },
    );
  }
}

// Interest Button Widget
class InterestButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function onTap;

  InterestButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.only(right: 16, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.4) : null,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: label.contains('http') ? Image.network(label, height: 28,) : Text(label),
      ),
    );
  }
}
