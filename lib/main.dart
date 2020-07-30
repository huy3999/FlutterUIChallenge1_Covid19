import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_ui_challenge_1/api/country_stat_api.dart';
import 'package:flutter_ui_challenge_1/model/country_stat.dart';
import 'package:flutter_ui_challenge_1/value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_ui_challenge_1/widgets/counter.dart';
import 'package:flutter_ui_challenge_1/model/global_stat.dart';
import 'package:flutter_ui_challenge_1/api/global_stat_api.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid 19',
      theme: ThemeData(
          scaffoldBackgroundColor: kBackgroundColor,
          fontFamily: "Poppins",
          textTheme: TextTheme(
            body1: TextStyle(color: kBodyTextColor),
          )),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ScrollController();
  double offset = 0;
  Future<GlobalStat> futureGlobalStat;
  Future<CountryStat> futureCountryStat;
  static const IconData refresh = IconData(0xe5d5, fontFamily: 'MaterialIcons');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    futureGlobalStat = fetchStats();
    futureCountryStat = fetchCountries();
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              child: FutureBuilder<CountryStat>(
                future: futureCountryStat,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String selectedValue;
                    List<DropdownMenuItem> items = [];
                    items.add(new DropdownMenuItem(
                      child: new Text(
                        'Global',
                      ),
                      value: 'Global',
                    ));
                    for (int i = 0; i < snapshot.data.countries.length; i++) {
                      items.add(new DropdownMenuItem(
                        child: new Text(
                          snapshot.data.countries.elementAt(i).country,
                        ),
                        value: snapshot.data.countries.elementAt(i).country,
                      ));
                    };
                    return new SearchableDropdown.single(
                      items: items,
                      value: selectedValue,
                      hint: "Select one",
                      searchHint: "Select one",
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                      isExpanded: true,
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return LinearProgressIndicator();
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Case Update",
                      style: kTitleTextstyle,
                    ),
                    subtitle: FutureBuilder<CountryStat>(
                      future: futureCountryStat,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var date = snapshot.data.countries.elementAt(0).date;
                          var dateSplit = date.split("T");
                          return Text(
                            'Latest update: ' + dateSplit[0],
                            style: TextStyle(
                              color: kTextLightColor,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return LinearProgressIndicator();
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.refresh, color: kPrimaryColor),
                      onPressed: () {
                        setState(() {
                          futureGlobalStat = fetchStats();
                          log('reload');
                        });
                      },
                    ),
                    dense: true,
                  ),
                  //SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 30,
                          color: kShadowColor,
                        ),
                      ],
                    ),
                    child: FutureBuilder<GlobalStat>(
                      future: futureGlobalStat,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Counter(
                                color: kInfectedColor,
                                number: snapshot.data.global.totalConfirmed,
                                title: "Infected",
                              ),
                              Counter(
                                color: kDeathColor,
                                number: snapshot.data.global.totalDeaths,
                                title: "Deaths",
                              ),
                              Counter(
                                color: kRecovercolor,
                                number: snapshot.data.global.totalRecovered,
                                title: "Recovered",
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ),
                  //SizedBox(height: 20),
                  ListTile(
                    title: Text(
                      "Spread of Virus",
                      style: kTitleTextstyle,
                    ),
                    trailing: Text(
                      "See details",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dense: true,
                  ),
                  SizedBox(
                    height: 600,
                    child: FutureBuilder<CountryStat>(
                      future: fetchCountries(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return _countryListView(snapshot.data.countries);
                        } else if (snapshot.hasError) {
                          return LinearProgressIndicator();
                        }
                        return LinearProgressIndicator();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _countryListView(data) {
    return ListView.builder(
        //shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _tile(data.elementAt(index).country,
              data.elementAt(index).totalConfirmed);
        });
  }

  ListTile _tile(String country, int totalConfirmed) => ListTile(
        title: Text(country,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(totalConfirmed.toString()),
      );
}
