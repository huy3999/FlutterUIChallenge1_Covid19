import 'dart:convert';
import 'package:flutter_ui_challenge_1/model/country_stat.dart';
import 'package:http/http.dart' as http;

Future<CountryStat> fetchCountries() async {
  final response = await http.get('https://api.covid19api.com/summary');

  if (response.statusCode == 200) {
    return CountryStat.fromJson(json.decode(response.body));
    // List jsonResponse = json.decode(response.body);
    // print(jsonResponse);
    // return jsonResponse.map((stat) => new CountryStat.fromJson(stat));
  } else {
    throw Exception('Failed to load stats from API');
  }
}
