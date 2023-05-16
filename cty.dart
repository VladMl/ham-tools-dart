import 'dart:io';

class Prefix {
  String name;
  int cq;
  int itu;
  double lat;
  double lon;
  double timeoffset;

  Prefix({this.name = "", this.cq = 0, this.itu = 0, this.lat = 0, this.lon = 0, this.timeoffset = 0});
}

class Country {
  String name;
  int code;
  String continent;
  int cq;
  int itu;
  double lat;
  double lon;
  double timeoffset;
  List<Prefix> prefixes = [];
  Set<String> callsigns = new Set();
  static final List<String> tokenCharacters = ['(', '[', '<', '{', '~'];

  Country({this.name = "", this.code = 0, this.continent = "", this.cq = 0, this.itu = 0, this.lat = 0, this.lon = 0, this.timeoffset = 0});

  static String extractPrefixPart(String str, String start, String end) {
    final startIndex = str.indexOf(start);
    int endIndex = -1;
    if (end == '~' && startIndex != -1)
      endIndex = str.indexOf(end, startIndex + 1);
    else
      endIndex = str.indexOf(end);
    if (startIndex != -1 && endIndex != -1)
      return str.substring(startIndex + start.length, endIndex).trim();
    else
      return '';
  }

  static String extractPrefix(String str) {
    int tokenStart = -1;
    for (var i = 0; i < tokenCharacters.length; i++) {
      tokenStart = str.indexOf(tokenCharacters[i]);
      if (tokenStart != -1) break;
    }
    if (tokenStart == -1)
      return str;
    else
      return str.substring(0, tokenStart);
  }

  Country substituteCountryInfo(Prefix prefix) {
    this.cq = prefix.cq != 0 ? prefix.cq : this.cq;
    this.itu = prefix.itu != 0 ? prefix.itu : this.itu;
    this.lat = prefix.lat != 0 ? prefix.lat : this.lat;
    this.lon = prefix.lon != 0 ? prefix.lon : this.lon;
    this.timeoffset = prefix.timeoffset != 0 ? prefix.timeoffset : this.timeoffset;
    return this;
  }

  void addPrefix(String str) {
    var cq = extractPrefixPart(str, '(', ')');
    var itu = extractPrefixPart(str, '[', ']');
    var lat = extractPrefixPart(str, '<', '>');
    var lon = extractPrefixPart(str, '{', '}');
    var timeoffset = extractPrefixPart(str, '~', '~');
    var prefix = extractPrefix(str);
    prefixes.add(Prefix(
        name: prefix,
        cq: cq.isEmpty != true ? int.parse(cq) : 0,
        itu: itu.isEmpty != true ? int.parse(itu) : 0,
        lat: lat.isEmpty != true ? double.parse(lat) : 0,
        lon: lon.isEmpty != true ? double.parse(lon) : 0,
        timeoffset: timeoffset.isEmpty != true ? double.parse(timeoffset) : 0));
  }

  void addCallsign(String callsign) {
    callsigns.add(callsign);
  }
}

class Cty {
  List<Country> countries = [];

  Country parseLine(String line) {
    var arr = line.split(',');

    Country country = new Country(
      name: arr[1].trim(),
      code: int.parse(arr[2].trim()),
      continent: arr[3].trim(),
      cq: int.parse(arr[4].trim()),
      itu: int.parse(arr[5].trim()),
      lat: double.parse(arr[6].trim()),
      lon: double.parse(arr[7].trim()),
      timeoffset: double.parse(arr[8].trim()),
    );

    country.addPrefix(arr[0].trim());

    var prefixes = arr[9].trim();
    var arrPrefixes = prefixes.trim().substring(0, prefixes.length - 1).split(' ');

    arrPrefixes.forEach((element) => {if (element[0] != "=") country.addPrefix(element) else country.addCallsign(element.substring(1))});

    return country;
  }

  void readCsv(String file) {
    List<String> lines = new File(file).readAsLinesSync();
    for (var line in lines) {
      countries.add(parseLine(line));
    }
  }

  Country? getCountry(String callsign) {
    Country? country = null;
    int countryIndex = -1;
    // iterate over callsigns
    for (var i = 0; i < countries.length; i++) {
      if (countries[i].callsigns.contains(callsign)) return countries[i];
    }
    ;

    // iterate over prefixes
    for (var i = 0; i < countries.length; i++) {
      for (var prefix in countries[i].prefixes) {
        if (callsign.substring(0, prefix.name.length) == prefix.name) {
          if (callsign.length > prefix.name.length) {
            if (double.tryParse(callsign.substring(prefix.name.length, prefix.name.length + 1)) != null) {
              return countries[i].substituteCountryInfo(prefix);
            }
//            else
//              return countries[i].substituteCountryInfo(prefix);
          } else 
          if (callsign.length == prefix.name.length) return countries[i].substituteCountryInfo(prefix);
        }
      }
    }
    return country;
  }
}
