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
                    }
                    ;
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
                },
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "Case Update\n",
                            style: kTitleTextstyle,
                            textAlign: TextAlign.left
                          ),
                          FutureBuilder<CountryStat>(
                            future: futureCountryStat,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var date =
                                    snapshot.data.countries.elementAt(0).date;
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
                              return CircularProgressIndicator();
                            },
                          )
                        ],
                      ),
                      Spacer(),
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            futureGlobalStat = fetchStats();
                            log('reload');
                          });
                        },
                        child: Text(
                          "Reload",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Spread of Virus",
                        style: kTitleTextstyle,
                      ),
                      Text(
                        "See details",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<CountryStat>(
                    future: fetchCountries(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        //CountryStat data = snapshot.data;
                        //return new Text(snapshot.data.countries.elementAt(1).country);
                        Expanded(
                          child: _countryListView(snapshot.data.countries),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                    },
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
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _tile(data.elementAt(index).country,
              data.elementAt(index).totalConfirmed);
        });
  }

  ListTile _tile(String country, String totalConfirmed) => ListTile(
        title: Text(country,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Text(totalConfirmed),
      );
}
