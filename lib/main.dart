import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_ui_challenge_1/api/country_stat_api.dart';
import 'package:flutter_ui_challenge_1/model/country_stat.dart';
import 'package:flutter_ui_challenge_1/value.dart';
import 'package:flutter_ui_challenge_1/widgets/counter.dart';
import 'package:flutter_ui_challenge_1/model/global_stat.dart';
import 'package:flutter_ui_challenge_1/api/global_stat_api.dart';

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
  String dropdownValue = "Descending";
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
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40),bottomRight: Radius.circular(40)),
                border: Border.all(
                  color: Color(0xFFE5E5E5),
                ),
              ),
              child: Center(child: 
                      Text("Covid-19", style: kHeadingTextStyle,) ,)
              
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Global Case Update",
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
                          futureCountryStat = fetchCountries();
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
                    trailing: DropdownButton<String>(
                      value: dropdownValue,
                      icon: Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(color: kPrimaryColor),
                      underline: Container(
                        height: 2,
                        color: kPrimaryColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['Descending', 'Ascending']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    dense: true,
                  ),
                  SizedBox(
                    height: 600,
                    child: FutureBuilder<CountryStat>(
                      future: fetchCountries(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (dropdownValue != null) {
                            if (dropdownValue == "Descending") {
                              return _countryListView(
                                  snapshot.data.countries, "des");
                            } else {
                              return _countryListView(
                                  snapshot.data.countries, "as");
                            }
                          }
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

  ListView _countryListView(data, sort) {
    if (sort == "as") {
      data.sort((Countries a, Countries b) =>
          a.totalConfirmed.compareTo(b.totalConfirmed));
    }
    else{
      data.sort((Countries a, Countries b) =>
          b.totalConfirmed.compareTo(a.totalConfirmed));
    }
    return ListView.builder(
        //shrinkWrap: true,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _tile(data.elementAt(index).country,
              data.elementAt(index).totalConfirmed, data.elementAt(index).totalDeaths, data.elementAt(index).totalRecovered);
        });
  }

  ListTile _tile(String country, int totalConfirmed, int totalDeaths, int totalRecovered) => ListTile(
        title: Text(country,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            )),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
          children: <Widget>[
            Text(totalConfirmed.toString(), style: TextStyle(color: kInfectedColor)),
            Text(totalDeaths.toString(), style: TextStyle(color: kDeathColor)),
            Text(totalRecovered.toString(), style: TextStyle(color: kRecovercolor))
          ],),
      );
}
