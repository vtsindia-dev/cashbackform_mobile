class StateModel {
  final int id;
  final int countryId;
  final String stateName;
  final int status;
  final String createdAt;
  final String updatedAt;

  StateModel({
    required this.id,
    required this.countryId,
    required this.stateName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      countryId: json['country_id'],
      stateName: json['state_name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static List<StateModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => StateModel.fromJson(e)).toList();
  }
}

class StateResponse {
  final int status;
  final String message;
  final List<StateModel> data;

  StateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StateResponse.fromJson(Map<String, dynamic> json) {
    return StateResponse(
      status: json['status'],
      message: json['message'],
      data: StateModel.listFromJson(json['data']),
    );
  }
}


class CountryModel {
  final int id;
  final String countryName;
  final int status;
  final String createdAt;
  final String updatedAt;

  CountryModel({
    required this.id,
    required this.countryName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      countryName: json['country_name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static List<CountryModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => CountryModel.fromJson(e)).toList();
  }
}

class CountryResponse {
  final int status;
  final String message;
  final List<CountryModel> data;

  CountryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) {
    return CountryResponse(
      status: json['status'],
      message: json['message'],
      data: CountryModel.listFromJson(json['data']),
    );
  }
}


class CityModel {
  final int id;
  final int stateId;
  final String cityName;
  final int status;
  final String createdAt;
  final String updatedAt;

  CityModel({
    required this.id,
    required this.stateId,
    required this.cityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      stateId: json['state_id'],
      cityName: json['city_name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static List<CityModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => CityModel.fromJson(e)).toList();
  }
}

class CityResponse {
  final int status;
  final List<CityModel> data;

  CityResponse({
    required this.status,
    required this.data,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      status: json['status'],
      data: CityModel.listFromJson(json['data']),
    );
  }
}