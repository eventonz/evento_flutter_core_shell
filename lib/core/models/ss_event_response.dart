import 'dart:convert';

// Main Response Class
class SSEventResponse {
  final int? currentPage;
  final int? from;
  final String? firstPageUrl;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final int? to;
  final int? total;
  final List<EventData>? data;

  SSEventResponse({
    required this.currentPage,
    required this.from,
    required this.firstPageUrl,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
    required this.data,
  });

  factory SSEventResponse.fromJson(Map<String, dynamic> json) {
    return SSEventResponse(
      currentPage: json['current_page'],
      from: json['from'],
      firstPageUrl: json['first_page_url'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
      data: List<EventData>.from(json['data'].map((item) => EventData.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'first_page_url': firstPageUrl,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

// EventData Class
class EventData {
  final int eventId;
  final String name;
  final int order;
  final List<Gender> genders;
  final List<Category> categories;
  final List<TeamType> teamTypes;
  final List<Attribute> attributes;
  final List<Club> clubs;
  final List<Country> countries;

  EventData({
    required this.eventId,
    required this.name,
    required this.order,
    required this.genders,
    required this.categories,
    required this.teamTypes,
    required this.attributes,
    required this.clubs,
    required this.countries,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventId: json['event_id'],
      name: json['name'],
      order: json['order'],
      genders: List<Gender>.from(json['genders'].map((item) => Gender.fromJson(item))),
      categories: List<Category>.from(json['categories'].map((item) => Category.fromJson(item))),
      teamTypes: List<TeamType>.from(json['team_types'].map((item) => TeamType.fromJson(item))),
      attributes: List<Attribute>.from(json['attributes'].map((item) => Attribute.fromJson(item))),
      clubs: List<Club>.from(json['clubs'].map((item) => Club.fromJson(item))),
      countries: List<Country>.from(json['countries'].map((item) => Country.fromJson(item))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'name': name,
      'order': order,
      'genders': genders.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
      'team_types': teamTypes.map((item) => item.toJson()).toList(),
      'attributes': attributes.map((item) => item.toJson()).toList(),
      'clubs': clubs.map((item) => item.toJson()).toList(),
      'countries': countries.map((item) => item.toJson()).toList(),
    };
  }
}

// Gender Class
class Gender {
  final int id;
  final String code;
  final String name;
  final bool enabled;

  Gender({
    required this.id,
    required this.code,
    required this.name,
    required this.enabled,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    print(json);
    return Gender(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'enabled': enabled,
    };
  }
}

// Category Class
class Category {
  final int? id;
  final String? code;
  final String? name;

  final int? order;
  final String? spotterDescription;
  final int? fromAge;
  final int? toAge;
  final int? onDate;

  Category({
    required this.id,
    required this.code,
    required this.name,
    required this.order,
    required this.spotterDescription,
    required this.fromAge,
    required this.toAge,
    required this.onDate,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    print(json);
    return Category(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      order: json['order'],
      spotterDescription: json['spotter_description'],
      fromAge: json['from_age'],
      toAge: json['to_age'],
      onDate: json['on_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'order': order,
      'spotter_description': spotterDescription,
      'from_age': fromAge,
      'to_age': toAge,
      'on_date': onDate,
    };
  }
}

// TeamType Class
class TeamType {
  final int id;
  final String name;
  final bool isActive;
  final bool allowOverallPos;
  final int order;

  TeamType({
    required this.id,
    required this.name,
    required this.isActive,
    required this.allowOverallPos,
    required this.order,
  });

  factory TeamType.fromJson(Map<String, dynamic> json) {
    return TeamType(
      id: json['id'],
      name: json['name'],
      isActive: json['is_active'],
      allowOverallPos: json['allow_overall_pos'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
      'allow_overall_pos': allowOverallPos,
      'order': order,
    };
  }
}

// Attribute Class
class Attribute {
  final int id;
  final String name;
  final String webName;
  final String slug;
  final String description;
  final int order;

  Attribute({
    required this.id,
    required this.name,
    required this.webName,
    required this.slug,
    required this.description,
    required this.order,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'],
      name: json['name'],
      webName: json['web_name'],
      slug: json['slug'],
      description: json['description'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'web_name': webName,
      'slug': slug,
      'description': description,
      'order': order,
    };
  }
}

// Club Class
class Club {
  final int id;
  final String code;
  final String name;

  Club({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

// Country Class
class Country {
  final int? id;
  final String? code;
  final String? name;
  final String? ioc;
  final String? iso2;

  Country({
    required this.id,
    required this.code,
    required this.name,
    required this.ioc,
    required this.iso2,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    print('country');
    print(json);
    return Country(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      ioc: json['IOC'],
      iso2: json['ISO2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'IOC': ioc,
      'ISO2': iso2,
    };
  }
}
