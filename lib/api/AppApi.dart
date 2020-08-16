import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wuhan/models/AppApiModel.dart';

class AppApi {
  static Future<ApiModel> fetch28() async {
    final ByCountryUrl = "https://corona-24h.herokuapp.com/enquire28";
    final response = await http.get(ByCountryUrl);
    return ApiModel.fromJson(jsonDecode(response.body.toString()));
  }

  static Future<ApiModel> fetch47() async {
    final ByCountryUrl = "https://corona-24h.herokuapp.com/enquire47";
    final response = await http.get(ByCountryUrl);
    return ApiModel.fromJson(jsonDecode(response.body.toString()));
  }

  static Future<ApiModel> fetch72() async {
    final ByCountryUrl = "https://corona-24h.herokuapp.com/enquire72";
    final response = await http.get(ByCountryUrl);
    return ApiModel.fromJson(jsonDecode(response.body.toString()));
  }
}
