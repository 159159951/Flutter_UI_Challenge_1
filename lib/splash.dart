import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wuhan/api/AppApi.dart';
import 'package:wuhan/map.dart';
import 'package:wuhan/multilanguage/app_translations.dart';
import 'package:wuhan/util/util.dart';

class SplashRoute extends StatefulWidget {
  @override
  _SplashRouteState createState() => _SplashRouteState();
}

class _SplashRouteState extends State<SplashRoute> {
  var connectionError = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    checkAppStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (connectionError) {
      return Container(
        color: Colors.grey,
        child: InkWell(
          child: Center(
            child: Text(
              AppTranslations.of(context).text("err_can_not_conn"),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
          ),
          onTap: () {
            checkAppStatus();
          },
        ),
      );
    } else {
      return Container(
        child: FlareActor("assets/flare/loading_black.flr",
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: "loading"),
      );
    }
  }

  Future<void> checkAppStatus() async {
    setState(() {
      connectionError = false;
    });
    prefs = await SharedPreferences.getInstance();
    try {
      var data28 = await AppApi.fetch28();
      var data47 = await AppApi.fetch47();
      var data72 = await AppApi.fetch72();
      await prefs.setString(Util.KEY_DATA_28, jsonEncode(data28.toJson()));
      await prefs.setString(Util.KEY_DATA_47, jsonEncode(data47.toJson()));
      await prefs.setString(Util.KEY_DATA_72, jsonEncode(data72.toJson()));
      gotoMapRoute();
    } catch (e) {
      setState(() {
        connectionError = true;
      });
    }
  }

  void gotoMapRoute() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MapRoute()),
    );
  }
}
