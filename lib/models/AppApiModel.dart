class ApiModel {
  String objectIdFieldName;
  UniqueIdField uniqueIdField;
  String globalIdFieldName;
  String geometryType;
  SpatialReference spatialReference;
  List<Fields> fields;
  List<Features> features;

  ApiModel(
      {this.objectIdFieldName,
        this.uniqueIdField,
        this.globalIdFieldName,
        this.geometryType,
        this.spatialReference,
        this.fields,
        this.features});

  ApiModel.fromJson(Map<String, dynamic> json) {
    objectIdFieldName = json['objectIdFieldName'];
    uniqueIdField = json['uniqueIdField'] != null
        ? new UniqueIdField.fromJson(json['uniqueIdField'])
        : null;
    globalIdFieldName = json['globalIdFieldName'];
    geometryType = json['geometryType'];
    spatialReference = json['spatialReference'] != null
        ? new SpatialReference.fromJson(json['spatialReference'])
        : null;
    if (json['fields'] != null) {
      fields = new List<Fields>();
      json['fields'].forEach((v) {
        fields.add(new Fields.fromJson(v));
      });
    }
    if (json['features'] != null) {
      features = new List<Features>();
      json['features'].forEach((v) {
        features.add(new Features.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['objectIdFieldName'] = this.objectIdFieldName;
    if (this.uniqueIdField != null) {
      data['uniqueIdField'] = this.uniqueIdField.toJson();
    }
    data['globalIdFieldName'] = this.globalIdFieldName;
    data['geometryType'] = this.geometryType;
    if (this.spatialReference != null) {
      data['spatialReference'] = this.spatialReference.toJson();
    }
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    if (this.features != null) {
      data['features'] = this.features.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UniqueIdField {
  String name;
  bool isSystemMaintained;

  UniqueIdField({this.name, this.isSystemMaintained});

  UniqueIdField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isSystemMaintained = json['isSystemMaintained'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isSystemMaintained'] = this.isSystemMaintained;
    return data;
  }
}

class SpatialReference {
  int wkid;
  int latestWkid;

  SpatialReference({this.wkid, this.latestWkid});

  SpatialReference.fromJson(Map<String, dynamic> json) {
    wkid = json['wkid'];
    latestWkid = json['latestWkid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wkid'] = this.wkid;
    data['latestWkid'] = this.latestWkid;
    return data;
  }
}

class Fields {
  String name;
  String type;
  String alias;
  String sqlType;
  Null domain;
  Null defaultValue;
  int length;

  Fields(
      {this.name,
        this.type,
        this.alias,
        this.sqlType,
        this.domain,
        this.defaultValue,
        this.length});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    alias = json['alias'];
    sqlType = json['sqlType'];
    domain = json['domain'];
    defaultValue = json['defaultValue'];
    length = json['length'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['alias'] = this.alias;
    data['sqlType'] = this.sqlType;
    data['domain'] = this.domain;
    data['defaultValue'] = this.defaultValue;
    data['length'] = this.length;
    return data;
  }
}

class Features {
  Attributes attributes;

  Features({this.attributes});

  Features.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.attributes != null) {
      data['attributes'] = this.attributes.toJson();
    }
    return data;
  }
}

class Attributes {
  int oBJECTID;
  String provinceState;
  String countryRegion;
  num lastUpdate;
  num lat;
  num long;
  int confirmed;
  int deaths;
  int recovered;

  Attributes(
      {this.oBJECTID,
        this.provinceState,
        this.countryRegion,
        this.lastUpdate,
        this.lat,
        this.long,
        this.confirmed,
        this.deaths,
        this.recovered});

  Attributes.fromJson(Map<String, dynamic> json) {
    oBJECTID = json['OBJECTID'];
    provinceState = json['Province_State'];
    countryRegion = json['Country_Region'];
    lastUpdate = json['Last_Update'];
    lat = json['Lat'];
    long = json['Long_'];
    confirmed = json['Confirmed'];
    deaths = json['Deaths'];
    recovered = json['Recovered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OBJECTID'] = this.oBJECTID;
    data['Province_State'] = this.provinceState;
    data['Country_Region'] = this.countryRegion;
    data['Last_Update'] = this.lastUpdate;
    data['Lat'] = this.lat;
    data['Long_'] = this.long;
    data['Confirmed'] = this.confirmed;
    data['Deaths'] = this.deaths;
    data['Recovered'] = this.recovered;
    return data;
  }
}
