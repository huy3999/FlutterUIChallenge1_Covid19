import 'dart:convert';
import 'package:flutter_ui_challenge_1/model/global_stat.dart';
import 'package:http/http.dart' as http;

Future<GlobalStat> fetchStats() async {
  
  final response = await http.get('https://api.covid19api.com/summary');
  //final response = await http.get('https://jsonplaceholder.typicode.com/albums/1');

  if (response.statusCode == 200) {
    return GlobalStat.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load stats from API');
  }
}
