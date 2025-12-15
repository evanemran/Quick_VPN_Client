class IpInfo {
  String? aboutUs;
  String? ip;
  bool? success;
  String? type;
  String? continent;
  String? continentCode;
  String? country;
  String? countryCode;
  String? region;
  String? regionCode;
  String? city;
  double? latitude;
  double? longitude;
  bool? isEu;
  String? postal;
  String? callingCode;
  String? capital;
  String? borders;
  Flag? flag;
  Connection? connection;
  Timezone? timezone;

  IpInfo(
      {this.aboutUs,
        this.ip,
        this.success,
        this.type,
        this.continent,
        this.continentCode,
        this.country,
        this.countryCode,
        this.region,
        this.regionCode,
        this.city,
        this.latitude,
        this.longitude,
        this.isEu,
        this.postal,
        this.callingCode,
        this.capital,
        this.borders,
        this.flag,
        this.connection,
        this.timezone});

  IpInfo.fromJson(Map<String, dynamic> json) {
    aboutUs = json['About_Us'];
    ip = json['ip'];
    success = json['success'];
    type = json['type'];
    continent = json['continent'];
    continentCode = json['continent_code'];
    country = json['country'];
    countryCode = json['country_code'];
    region = json['region'];
    regionCode = json['region_code'];
    city = json['city'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isEu = json['is_eu'];
    postal = json['postal'];
    callingCode = json['calling_code'];
    capital = json['capital'];
    borders = json['borders'];
    flag = json['flag'] != null ? new Flag.fromJson(json['flag']) : null;
    connection = json['connection'] != null
        ? new Connection.fromJson(json['connection'])
        : null;
    timezone = json['timezone'] != null
        ? new Timezone.fromJson(json['timezone'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['About_Us'] = this.aboutUs;
    data['ip'] = this.ip;
    data['success'] = this.success;
    data['type'] = this.type;
    data['continent'] = this.continent;
    data['continent_code'] = this.continentCode;
    data['country'] = this.country;
    data['country_code'] = this.countryCode;
    data['region'] = this.region;
    data['region_code'] = this.regionCode;
    data['city'] = this.city;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['is_eu'] = this.isEu;
    data['postal'] = this.postal;
    data['calling_code'] = this.callingCode;
    data['capital'] = this.capital;
    data['borders'] = this.borders;
    if (this.flag != null) {
      data['flag'] = this.flag!.toJson();
    }
    if (this.connection != null) {
      data['connection'] = this.connection!.toJson();
    }
    if (this.timezone != null) {
      data['timezone'] = this.timezone!.toJson();
    }
    return data;
  }
}

class Flag {
  String? img;
  String? emoji;
  String? emojiUnicode;

  Flag({this.img, this.emoji, this.emojiUnicode});

  Flag.fromJson(Map<String, dynamic> json) {
    img = json['img'];
    emoji = json['emoji'];
    emojiUnicode = json['emoji_unicode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['img'] = this.img;
    data['emoji'] = this.emoji;
    data['emoji_unicode'] = this.emojiUnicode;
    return data;
  }
}

class Connection {
  int? asn;
  String? org;
  String? isp;
  String? domain;

  Connection({this.asn, this.org, this.isp, this.domain});

  Connection.fromJson(Map<String, dynamic> json) {
    asn = json['asn'];
    org = json['org'];
    isp = json['isp'];
    domain = json['domain'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['asn'] = this.asn;
    data['org'] = this.org;
    data['isp'] = this.isp;
    data['domain'] = this.domain;
    return data;
  }
}

class Timezone {
  String? id;
  String? abbr;
  bool? isDst;
  int? offset;
  String? utc;
  String? currentTime;

  Timezone(
      {this.id,
        this.abbr,
        this.isDst,
        this.offset,
        this.utc,
        this.currentTime});

  Timezone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    abbr = json['abbr'];
    isDst = json['is_dst'];
    offset = json['offset'];
    utc = json['utc'];
    currentTime = json['current_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['abbr'] = this.abbr;
    data['is_dst'] = this.isDst;
    data['offset'] = this.offset;
    data['utc'] = this.utc;
    data['current_time'] = this.currentTime;
    return data;
  }
}
