import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wuhan/api/AppApi.dart';
import 'package:wuhan/models/AppApiModel.dart';
import 'package:wuhan/multilanguage/app_translations.dart';
import 'package:wuhan/util/util.dart';

class StatisticRoute extends StatefulWidget {
  StatisticRoute(this.data28);

  ApiModel data28;

  @override
  _StatisticRouteState createState() => _StatisticRouteState();
}

class _StatisticRouteState extends State<StatisticRoute> {
  final formatter = new NumberFormat("#,###");
  var lastUpdate = "";
  var aniIndex = 0;
  final aniName = ["start", "middle", "react"];
  var visibleVirusAni = true;

  final FlareControls flareControl = FlareControls();

  @override
  void initState() {
    super.initState();
    _calculateLatestUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppTranslations.of(context).text("statistic"),
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _lastUpdateWidget(),
                _summaryRow(),
                Container(
                  height: 2,
                ),
                _detailRow(),
                _mapImageWidget(),
              ],
            ),
          ),
          Visibility(
            visible: visibleVirusAni,
            child: InkWell(
              onTap: () {
                setState(() {
                  aniIndex++;
                });
              },
              child: Container(
                color: Color(0xa0000000),
                width: double.infinity,
                height: double.infinity,
                child: FlareActor(
                  "assets/flare/virus.flr",
                  animation: aniName[aniIndex],
                  callback: (ani) {
                    if (ani == aniName[2]) {
                      setState(() {
                        visibleVirusAni = false;
                      });
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _getTotalConfirmed(FilterType sumType) {
    if (widget.data28 == null) return "-";
    num total = 0;

    widget.data28.features.forEach((f) {
      switch (sumType) {
        case FilterType.CONFIRMED:
          total += f.attributes.confirmed ?? 0;
          break;
        case FilterType.DEAD:
          total += f.attributes.deaths ?? 0;
          break;
        case FilterType.RECOVERED:
          total += f.attributes.recovered ?? 0;
          break;
      }
    });

    return formatter.format(total);
  }

  Widget _summaryRow() {
    return Row(children: <Widget>[
      Expanded(child: _summaryWidget(FilterType.CONFIRMED)),
      Expanded(child: _summaryWidget(FilterType.DEAD)),
      Expanded(child: _summaryWidget(FilterType.RECOVERED))
    ]);
  }

  Widget _summaryWidget(FilterType filterType) {
    var title = "";
    var value = "";
    var txtColor = Colors.white;

    switch (filterType) {
      case FilterType.CONFIRMED:
        title = AppTranslations.of(context).text("total_confirm");
        value = _getTotalConfirmed(FilterType.CONFIRMED);
        txtColor = Colors.redAccent;
        break;
      case FilterType.DEAD:
        title = AppTranslations.of(context).text("total_deads");
        value = _getTotalConfirmed(FilterType.DEAD);
        txtColor = Colors.white;
        break;
      case FilterType.RECOVERED:
        title = AppTranslations.of(context).text("total_recoved");
        value = _getTotalConfirmed(FilterType.RECOVERED);
        txtColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(1)),
          color: Color(0xff222222),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(children: <Widget>[
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              value,
              style: TextStyle(
                  color: txtColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            InkWell(
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
              ),
              onTap: () {
                _sort(filterType);
                setState(() {});
              },
            ),
          ]),
        ),
      ),
    );
  }

  _sort(FilterType filterType) {
    switch (filterType) {
      case FilterType.CONFIRMED:
        widget.data28.features.sort((featureLeft, featureRight) {
          return featureRight.attributes.confirmed -
              featureLeft.attributes.confirmed;
        });
        break;
      case FilterType.DEAD:
        widget.data28.features.sort((featureLeft, featureRight) {
          return featureRight.attributes.deaths - featureLeft.attributes.deaths;
        });
        break;
      case FilterType.RECOVERED:
        widget.data28.features.sort((featureLeft, featureRight) {
          return featureRight.attributes.recovered -
              featureLeft.attributes.recovered;
        });
        break;
    }
  }

  Widget _detailRow() {
    return Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
                color: Color(0xff222222),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _detailTable(FilterType.CONFIRMED),
                )),
          )),
      Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
                color: Color(0xff222222),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _detailTable(FilterType.DEAD),
                )),
          )),
      Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
                color: Color(0xff222222),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _detailTable(FilterType.RECOVERED),
                )),
          ))
    ]);
  }

  Widget _detailTable(FilterType sumType) {
    var lstWidget = List<Widget>();

    widget.data28.features.forEach((location) {
      switch (sumType) {
        case FilterType.CONFIRMED:
          lstWidget.add(Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatter.format(location.attributes.confirmed),
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  Text(
                    location.attributes.countryRegion,
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ]),
          ));
          break;
        case FilterType.DEAD:
          lstWidget.add(Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatter.format(location.attributes.deaths),
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    location.attributes.countryRegion,
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ]),
          ));
          break;
        case FilterType.RECOVERED:
          lstWidget.add(Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatter.format(location.attributes.recovered ?? 0),
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    location.attributes.countryRegion,
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    height: 1,
                    color: Colors.white,
                  ),
                ]),
          ));
          break;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lstWidget,
    );
  }

  Widget _mapImageWidget() {
    return SafeArea(
      child: Container(
          width: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppTranslations.of(context).text("map_image_title"),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Image.network(Util.nCoVMapURL)
              ])),
    );
  }

  Widget _lastUpdateWidget() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: double.infinity,
        color: Color(0xff222222),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(AppTranslations.of(context).text("update_time"),
                        style: TextStyle(color: Colors.green)),
                    Text(lastUpdate,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  width: 40,
                  height: 40,
                  child: FlareActor("assets/flare/reload.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.fill,
                      controller: flareControl,
                      animation: "go"),
                ),
                onTap: () {
                  flareControl.play("go");
                  _getLatestData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _calculateLatestUpdate() async {
    num maxDate = 0;
    widget.data28.features.forEach((feature) {
      if (feature.attributes.lastUpdate > maxDate) {
        maxDate = feature.attributes.lastUpdate;
      }
    });

    DateFormat format = new DateFormat('HH:mm yyyy-MM-dd');
    DateTime time = DateTime.fromMillisecondsSinceEpoch(maxDate);
    lastUpdate = format.format(time.toLocal());

    setState(() {});
  }

  _getLatestData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var data28Latest = await AppApi.fetch28();
      widget.data28 = data28Latest;
      await prefs.setString(
          Util.KEY_DATA_28, jsonEncode(data28Latest.toJson()));

      Toast.show(
        AppTranslations.of(context).text("data_up_to_date_message"),
        context,
        gravity: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        duration: 5,
      );
      setState(() {});
    } catch (e) {
      Toast.show(AppTranslations.of(context).text("err_can_not_conn"), context,
          duration: Toast.LENGTH_LONG);
    }
  }
}

enum FilterType { CONFIRMED, DEAD, RECOVERED }
