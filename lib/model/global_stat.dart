class GlobalStat {
  Global global;

  GlobalStat({this.global});

  GlobalStat.fromJson(Map<String, dynamic> json) {
    global =
        json['Global'] != null ? new Global.fromJson(json['Global']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.global != null) {
      data['Global'] = this.global.toJson();
    }
    return data;
  }
}

class Global {
  int newConfirmed;
  int totalConfirmed;
  int newDeaths;
  int totalDeaths;
  int newRecovered;
  int totalRecovered;

  Global(
      {this.newConfirmed,
      this.totalConfirmed,
      this.newDeaths,
      this.totalDeaths,
      this.newRecovered,
      this.totalRecovered});

  Global.fromJson(Map<String, dynamic> json) {
    newConfirmed = json['NewConfirmed'];
    totalConfirmed = json['TotalConfirmed'];
    newDeaths = json['NewDeaths'];
    totalDeaths = json['TotalDeaths'];
    newRecovered = json['NewRecovered'];
    totalRecovered = json['TotalRecovered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NewConfirmed'] = this.newConfirmed;
    data['TotalConfirmed'] = this.totalConfirmed;
    data['NewDeaths'] = this.newDeaths;
    data['TotalDeaths'] = this.totalDeaths;
    data['NewRecovered'] = this.newRecovered;
    data['TotalRecovered'] = this.totalRecovered;
    return data;
  }
}