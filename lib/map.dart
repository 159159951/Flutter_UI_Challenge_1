import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wuhan/models/AppApiModel.dart';
import 'package:wuhan/multilanguage/app_translations.dart';
import 'package:wuhan/statistic.dart';
import 'package:wuhan/util/util.dart';

class MapRoute extends StatefulWidget {
  ApiModel data28;
  ApiModel data47;
  ApiModel data72;

  @override
  State<MapRoute> createState() => MapRouteState();
}

class MapRouteState extends State<MapRoute>
    with SingleTickerProviderStateMixin {
  ApiModel dataShow;

  int currentIndex = 0;

  final ZOOM_STEP_1 = 3.5;
  final ZOOM_STEP_2 = 5;

  double _currentZoom = 8;

  Completer<GoogleMapController> _mapController = Completer();

  static final CameraPosition wuhan = CameraPosition(
    target: LatLng(30.567816, 114.0201948),
    zoom: 2,
  );

  Set<Circle> circles = Set.from([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildMap(context);
          }
        },
      ),
    );
  }

  Future<bool> _loadData() async {
    var sharePref = await SharedPreferences.getInstance();
    widget.data28 =
        ApiModel.fromJson(jsonDecode(sharePref.getString(Util.KEY_DATA_28)));
    widget.data47 =
        ApiModel.fromJson(jsonDecode(sharePref.getString(Util.KEY_DATA_47)));
    widget.data72 =
        ApiModel.fromJson(jsonDecode(sharePref.getString(Util.KEY_DATA_72)));
    return true;
  }

  Widget _buildMap(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: wuhan,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
          },
          onCameraIdle: () {
            print("Andy: onCameraIdle: ");
            _displayRedZones();
          },
          onCameraMove: (position) {
            print("Andy: onCameraMove: ${position.zoom}");
            _currentZoom = position.zoom;
          },
          circles: circles,
        ),
        Positioned(
          left: 10,
          width: 80,
          height: 80,
          bottom: 110,
          child: Container(
            decoration:
                BoxDecoration(color: Color(0x55ff4d88), shape: BoxShape.circle),
            child: InkWell(
              child: LayoutBuilder(
                builder: (context, constraint) {
                  return Icon(
                    Icons.navigate_before,
                    color: Colors.white60,
                    size: constraint.biggest.height,
                  );
                },
              ),
              onTap: () {
                _changeCountry(-1);
              },
            ),
          ),
        ),
        Positioned(
          right: 10,
          width: 80,
          height: 80,
          bottom: 110,
          child: Container(
            decoration:
                BoxDecoration(color: Color(0x55ff4d88), shape: BoxShape.circle),
            child: InkWell(
              child: LayoutBuilder(
                builder: (context, constraint) {
                  return Icon(
                    Icons.navigate_next,
                    color: Colors.white60,
                    size: constraint.biggest.height,
                  );
                },
              ),
              onTap: () {
                _changeCountry(1);
              },
            ),
          ),
        ),
        Positioned(
          right: 10,
          width: 100,
          height: 100,
          top: 110,
          child: Container(
            decoration:
                BoxDecoration(color: Color(0x55000000), shape: BoxShape.circle),
            child: InkWell(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 65,
                      height: 65,
                      child: FlareActor("assets/flare/warning.flr",
                          alignment: Alignment.center,
                          fit: BoxFit.fill,
                          animation: "warning"),
                    ),
                    Text(
                      AppTranslations.of(context).text("statistic"),
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    Text(""),
                  ]),
              onTap: () {
                _gotoStatisticRoute();
              },
            ),
          ),
        ),
      ],
    );
  }

  _displayRedZones() async {
    if (_currentZoom < ZOOM_STEP_1) {
      dataShow = widget.data28;
    } else if (_currentZoom < ZOOM_STEP_2) {
      dataShow = widget.data47;
    } else {
      dataShow = widget.data72;
    }

    dataShow.features.sort((left, right) {
      return right.attributes.confirmed - left.attributes.confirmed;
    });

    circles.clear();
    setState(() {});

    dataShow.features.forEach(
      (feature) {
        {
          circles.add(
            Circle(
              circleId: CircleId(feature.attributes.oBJECTID.toString()),
              center: LatLng(feature.attributes.lat.toDouble(),
                  feature.attributes.long.toDouble()),
              radius: feature.attributes.confirmed > 1000
                  ? feature.attributes.confirmed * 5.toDouble()
                  : feature.attributes.confirmed > 10
                      ? feature.attributes.confirmed * 3.toDouble()
                      : feature.attributes.confirmed * 7.toDouble(),
              fillColor: Color.fromARGB(20, 255, 0, 0),
              strokeColor: Color.fromARGB(20, 255, 0, 0),
              strokeWidth: 2,
              consumeTapEvents: true,
              onTap: () {
                Toast.show(
                    "${feature.attributes.provinceState ?? feature.attributes.countryRegion}"
                    "\n${AppTranslations.of(context).text("total_confirm")}:\t\t${feature.attributes.confirmed}"
                    "\n${AppTranslations.of(context).text("total_deads")}:\t\t${feature.attributes.deaths}"
                    "\n${AppTranslations.of(context).text("total_recoved")}:\t\t${feature.attributes.recovered}",
                    context,
                    duration: 2);
              },
            ),
          );
        }
      },
    );

    setState(() {});
  }

  bool _changeCountry(int step) {
    if (dataShow != null &&
        dataShow.features != null &&
        dataShow.features.length > 0) {
      final newIndex = currentIndex + step;
      if (0 <= newIndex && newIndex < dataShow.features.length) {
        currentIndex = newIndex;
      } else {
        currentIndex = 0;
      }

      if (_currentZoom < ZOOM_STEP_1) {
        _currentZoom = ZOOM_STEP_1;
      }

      _animateMapToSelectedCountry();
      return true;
    }
    return false;
  }

  _animateMapToSelectedCountry() async {
    final GoogleMapController controller = await _mapController.future;

    final CameraPosition camPos = CameraPosition(
        target: LatLng(
            dataShow.features[currentIndex].attributes.lat.toDouble(),
            dataShow.features[currentIndex].attributes.long.toDouble()),
        zoom: _currentZoom);

    controller.animateCamera(CameraUpdate.newCameraPosition(camPos));
  }

  void _gotoStatisticRoute() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatisticRoute(widget.data28)),
    );
    await _loadData();
    setState(() {});
  }
}
