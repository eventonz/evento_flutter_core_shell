// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $AthleteDbTable extends AthleteDb
    with TableInfo<$AthleteDbTable, AppAthleteDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AthleteDbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _athleteIdMeta =
      const VerificationMeta('athleteId');
  @override
  late final GeneratedColumn<String> athleteId = GeneratedColumn<String>(
      'athlete_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canFollowMeta =
      const VerificationMeta('canFollow');
  @override
  late final GeneratedColumn<bool> canFollow = GeneratedColumn<bool>(
      'can_follow', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("can_follow" IN (0, 1))'));
  static const VerificationMeta _isFollowedMeta =
      const VerificationMeta('isFollowed');
  @override
  late final GeneratedColumn<bool> isFollowed = GeneratedColumn<bool>(
      'is_followed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_followed" IN (0, 1))'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _extraMeta = const VerificationMeta('extra');
  @override
  late final GeneratedColumn<String> extra = GeneratedColumn<String>(
      'extra', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileImageMeta =
      const VerificationMeta('profileImage');
  @override
  late final GeneratedColumn<String> profileImage = GeneratedColumn<String>(
      'profile_image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _racenoMeta = const VerificationMeta('raceno');
  @override
  late final GeneratedColumn<int> raceno = GeneratedColumn<int>(
      'raceno', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
      'event_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _infoMeta = const VerificationMeta('info');
  @override
  late final GeneratedColumn<String> info = GeneratedColumn<String>(
      'info', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contestNoMeta =
      const VerificationMeta('contestNo');
  @override
  late final GeneratedColumn<int> contestNo = GeneratedColumn<int>(
      'contest_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _searchTagMeta =
      const VerificationMeta('searchTag');
  @override
  late final GeneratedColumn<String> searchTag = GeneratedColumn<String>(
      'search_tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        athleteId,
        canFollow,
        isFollowed,
        name,
        extra,
        profileImage,
        raceno,
        eventId,
        info,
        contestNo,
        searchTag
      ];
  @override
  String get aliasedName => _alias ?? 'athlete_db';
  @override
  String get actualTableName => 'athlete_db';
  @override
  VerificationContext validateIntegrity(Insertable<AppAthleteDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('athlete_id')) {
      context.handle(_athleteIdMeta,
          athleteId.isAcceptableOrUnknown(data['athlete_id']!, _athleteIdMeta));
    } else if (isInserting) {
      context.missing(_athleteIdMeta);
    }
    if (data.containsKey('can_follow')) {
      context.handle(_canFollowMeta,
          canFollow.isAcceptableOrUnknown(data['can_follow']!, _canFollowMeta));
    } else if (isInserting) {
      context.missing(_canFollowMeta);
    }
    if (data.containsKey('is_followed')) {
      context.handle(
          _isFollowedMeta,
          isFollowed.isAcceptableOrUnknown(
              data['is_followed']!, _isFollowedMeta));
    } else if (isInserting) {
      context.missing(_isFollowedMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('extra')) {
      context.handle(
          _extraMeta, extra.isAcceptableOrUnknown(data['extra']!, _extraMeta));
    } else if (isInserting) {
      context.missing(_extraMeta);
    }
    if (data.containsKey('profile_image')) {
      context.handle(
          _profileImageMeta,
          profileImage.isAcceptableOrUnknown(
              data['profile_image']!, _profileImageMeta));
    } else if (isInserting) {
      context.missing(_profileImageMeta);
    }
    if (data.containsKey('raceno')) {
      context.handle(_racenoMeta,
          raceno.isAcceptableOrUnknown(data['raceno']!, _racenoMeta));
    } else if (isInserting) {
      context.missing(_racenoMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('info')) {
      context.handle(
          _infoMeta, info.isAcceptableOrUnknown(data['info']!, _infoMeta));
    } else if (isInserting) {
      context.missing(_infoMeta);
    }
    if (data.containsKey('contest_no')) {
      context.handle(_contestNoMeta,
          contestNo.isAcceptableOrUnknown(data['contest_no']!, _contestNoMeta));
    } else if (isInserting) {
      context.missing(_contestNoMeta);
    }
    if (data.containsKey('search_tag')) {
      context.handle(_searchTagMeta,
          searchTag.isAcceptableOrUnknown(data['search_tag']!, _searchTagMeta));
    } else if (isInserting) {
      context.missing(_searchTagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppAthleteDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppAthleteDb(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      athleteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}athlete_id'])!,
      canFollow: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_follow'])!,
      isFollowed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_followed'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      extra: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra'])!,
      profileImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_image'])!,
      raceno: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}raceno'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}event_id'])!,
      info: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}info'])!,
      contestNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contest_no'])!,
      searchTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_tag'])!,
    );
  }

  @override
  $AthleteDbTable createAlias(String alias) {
    return $AthleteDbTable(attachedDatabase, alias);
  }
}

class AppAthleteDb extends DataClass implements Insertable<AppAthleteDb> {
  final int id;
  final String athleteId;
  final bool canFollow;
  final bool isFollowed;
  final String name;
  final String extra;
  final String profileImage;
  final int raceno;
  final int eventId;
  final String info;
  final int contestNo;
  final String searchTag;
  const AppAthleteDb(
      {required this.id,
      required this.athleteId,
      required this.canFollow,
      required this.isFollowed,
      required this.name,
      required this.extra,
      required this.profileImage,
      required this.raceno,
      required this.eventId,
      required this.info,
      required this.contestNo,
      required this.searchTag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['athlete_id'] = Variable<String>(athleteId);
    map['can_follow'] = Variable<bool>(canFollow);
    map['is_followed'] = Variable<bool>(isFollowed);
    map['name'] = Variable<String>(name);
    map['extra'] = Variable<String>(extra);
    map['profile_image'] = Variable<String>(profileImage);
    map['raceno'] = Variable<int>(raceno);
    map['event_id'] = Variable<int>(eventId);
    map['info'] = Variable<String>(info);
    map['contest_no'] = Variable<int>(contestNo);
    map['search_tag'] = Variable<String>(searchTag);
    return map;
  }

  AthleteDbCompanion toCompanion(bool nullToAbsent) {
    return AthleteDbCompanion(
      id: Value(id),
      athleteId: Value(athleteId),
      canFollow: Value(canFollow),
      isFollowed: Value(isFollowed),
      name: Value(name),
      extra: Value(extra),
      profileImage: Value(profileImage),
      raceno: Value(raceno),
      eventId: Value(eventId),
      info: Value(info),
      contestNo: Value(contestNo),
      searchTag: Value(searchTag),
    );
  }

  factory AppAthleteDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppAthleteDb(
      id: serializer.fromJson<int>(json['id']),
      athleteId: serializer.fromJson<String>(json['athleteId']),
      canFollow: serializer.fromJson<bool>(json['canFollow']),
      isFollowed: serializer.fromJson<bool>(json['isFollowed']),
      name: serializer.fromJson<String>(json['name']),
      extra: serializer.fromJson<String>(json['extra']),
      profileImage: serializer.fromJson<String>(json['profileImage']),
      raceno: serializer.fromJson<int>(json['raceno']),
      eventId: serializer.fromJson<int>(json['eventId']),
      info: serializer.fromJson<String>(json['info']),
      contestNo: serializer.fromJson<int>(json['contestNo']),
      searchTag: serializer.fromJson<String>(json['searchTag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'athleteId': serializer.toJson<String>(athleteId),
      'canFollow': serializer.toJson<bool>(canFollow),
      'isFollowed': serializer.toJson<bool>(isFollowed),
      'name': serializer.toJson<String>(name),
      'extra': serializer.toJson<String>(extra),
      'profileImage': serializer.toJson<String>(profileImage),
      'raceno': serializer.toJson<int>(raceno),
      'eventId': serializer.toJson<int>(eventId),
      'info': serializer.toJson<String>(info),
      'contestNo': serializer.toJson<int>(contestNo),
      'searchTag': serializer.toJson<String>(searchTag),
    };
  }

  AppAthleteDb copyWith(
          {int? id,
          String? athleteId,
          bool? canFollow,
          bool? isFollowed,
          String? name,
          String? extra,
          String? profileImage,
          int? raceno,
          int? eventId,
          String? info,
          int? contestNo,
          String? searchTag}) =>
      AppAthleteDb(
        id: id ?? this.id,
        athleteId: athleteId ?? this.athleteId,
        canFollow: canFollow ?? this.canFollow,
        isFollowed: isFollowed ?? this.isFollowed,
        name: name ?? this.name,
        extra: extra ?? this.extra,
        profileImage: profileImage ?? this.profileImage,
        raceno: raceno ?? this.raceno,
        eventId: eventId ?? this.eventId,
        info: info ?? this.info,
        contestNo: contestNo ?? this.contestNo,
        searchTag: searchTag ?? this.searchTag,
      );
  @override
  String toString() {
    return (StringBuffer('AppAthleteDb(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('canFollow: $canFollow, ')
          ..write('isFollowed: $isFollowed, ')
          ..write('name: $name, ')
          ..write('extra: $extra, ')
          ..write('profileImage: $profileImage, ')
          ..write('raceno: $raceno, ')
          ..write('eventId: $eventId, ')
          ..write('info: $info, ')
          ..write('contestNo: $contestNo, ')
          ..write('searchTag: $searchTag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, athleteId, canFollow, isFollowed, name,
      extra, profileImage, raceno, eventId, info, contestNo, searchTag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppAthleteDb &&
          other.id == this.id &&
          other.athleteId == this.athleteId &&
          other.canFollow == this.canFollow &&
          other.isFollowed == this.isFollowed &&
          other.name == this.name &&
          other.extra == this.extra &&
          other.profileImage == this.profileImage &&
          other.raceno == this.raceno &&
          other.eventId == this.eventId &&
          other.info == this.info &&
          other.contestNo == this.contestNo &&
          other.searchTag == this.searchTag);
}

class AthleteDbCompanion extends UpdateCompanion<AppAthleteDb> {
  final Value<int> id;
  final Value<String> athleteId;
  final Value<bool> canFollow;
  final Value<bool> isFollowed;
  final Value<String> name;
  final Value<String> extra;
  final Value<String> profileImage;
  final Value<int> raceno;
  final Value<int> eventId;
  final Value<String> info;
  final Value<int> contestNo;
  final Value<String> searchTag;
  const AthleteDbCompanion({
    this.id = const Value.absent(),
    this.athleteId = const Value.absent(),
    this.canFollow = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.name = const Value.absent(),
    this.extra = const Value.absent(),
    this.profileImage = const Value.absent(),
    this.raceno = const Value.absent(),
    this.eventId = const Value.absent(),
    this.info = const Value.absent(),
    this.contestNo = const Value.absent(),
    this.searchTag = const Value.absent(),
  });
  AthleteDbCompanion.insert({
    this.id = const Value.absent(),
    required String athleteId,
    required bool canFollow,
    required bool isFollowed,
    required String name,
    required String extra,
    required String profileImage,
    required int raceno,
    required int eventId,
    required String info,
    required int contestNo,
    required String searchTag,
  })  : athleteId = Value(athleteId),
        canFollow = Value(canFollow),
        isFollowed = Value(isFollowed),
        name = Value(name),
        extra = Value(extra),
        profileImage = Value(profileImage),
        raceno = Value(raceno),
        eventId = Value(eventId),
        info = Value(info),
        contestNo = Value(contestNo),
        searchTag = Value(searchTag);
  static Insertable<AppAthleteDb> custom({
    Expression<int>? id,
    Expression<String>? athleteId,
    Expression<bool>? canFollow,
    Expression<bool>? isFollowed,
    Expression<String>? name,
    Expression<String>? extra,
    Expression<String>? profileImage,
    Expression<int>? raceno,
    Expression<int>? eventId,
    Expression<String>? info,
    Expression<int>? contestNo,
    Expression<String>? searchTag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (athleteId != null) 'athlete_id': athleteId,
      if (canFollow != null) 'can_follow': canFollow,
      if (isFollowed != null) 'is_followed': isFollowed,
      if (name != null) 'name': name,
      if (extra != null) 'extra': extra,
      if (profileImage != null) 'profile_image': profileImage,
      if (raceno != null) 'raceno': raceno,
      if (eventId != null) 'event_id': eventId,
      if (info != null) 'info': info,
      if (contestNo != null) 'contest_no': contestNo,
      if (searchTag != null) 'search_tag': searchTag,
    });
  }

  AthleteDbCompanion copyWith(
      {Value<int>? id,
      Value<String>? athleteId,
      Value<bool>? canFollow,
      Value<bool>? isFollowed,
      Value<String>? name,
      Value<String>? extra,
      Value<String>? profileImage,
      Value<int>? raceno,
      Value<int>? eventId,
      Value<String>? info,
      Value<int>? contestNo,
      Value<String>? searchTag}) {
    return AthleteDbCompanion(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      canFollow: canFollow ?? this.canFollow,
      isFollowed: isFollowed ?? this.isFollowed,
      name: name ?? this.name,
      extra: extra ?? this.extra,
      profileImage: profileImage ?? this.profileImage,
      raceno: raceno ?? this.raceno,
      eventId: eventId ?? this.eventId,
      info: info ?? this.info,
      contestNo: contestNo ?? this.contestNo,
      searchTag: searchTag ?? this.searchTag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (athleteId.present) {
      map['athlete_id'] = Variable<String>(athleteId.value);
    }
    if (canFollow.present) {
      map['can_follow'] = Variable<bool>(canFollow.value);
    }
    if (isFollowed.present) {
      map['is_followed'] = Variable<bool>(isFollowed.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (profileImage.present) {
      map['profile_image'] = Variable<String>(profileImage.value);
    }
    if (raceno.present) {
      map['raceno'] = Variable<int>(raceno.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (info.present) {
      map['info'] = Variable<String>(info.value);
    }
    if (contestNo.present) {
      map['contest_no'] = Variable<int>(contestNo.value);
    }
    if (searchTag.present) {
      map['search_tag'] = Variable<String>(searchTag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AthleteDbCompanion(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('canFollow: $canFollow, ')
          ..write('isFollowed: $isFollowed, ')
          ..write('name: $name, ')
          ..write('extra: $extra, ')
          ..write('profileImage: $profileImage, ')
          ..write('raceno: $raceno, ')
          ..write('eventId: $eventId, ')
          ..write('info: $info, ')
          ..write('contestNo: $contestNo, ')
          ..write('searchTag: $searchTag')
          ..write(')'))
        .toString();
  }
}

class $AthleteExtraDetailsDbTable extends AthleteExtraDetailsDb
    with TableInfo<$AthleteExtraDetailsDbTable, AppAthleteExtraDetailsDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AthleteExtraDetailsDbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _athleteIdMeta =
      const VerificationMeta('athleteId');
  @override
  late final GeneratedColumn<String> athleteId = GeneratedColumn<String>(
      'athlete_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
      'event_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _athleteNumberMeta =
      const VerificationMeta('athleteNumber');
  @override
  late final GeneratedColumn<String> athleteNumber = GeneratedColumn<String>(
      'athlete_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, athleteId, name, eventId, country, athleteNumber];
  @override
  String get aliasedName => _alias ?? 'athlete_extra_details_db';
  @override
  String get actualTableName => 'athlete_extra_details_db';
  @override
  VerificationContext validateIntegrity(
      Insertable<AppAthleteExtraDetailsDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('athlete_id')) {
      context.handle(_athleteIdMeta,
          athleteId.isAcceptableOrUnknown(data['athlete_id']!, _athleteIdMeta));
    } else if (isInserting) {
      context.missing(_athleteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('athlete_number')) {
      context.handle(
          _athleteNumberMeta,
          athleteNumber.isAcceptableOrUnknown(
              data['athlete_number']!, _athleteNumberMeta));
    } else if (isInserting) {
      context.missing(_athleteNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppAthleteExtraDetailsDb map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppAthleteExtraDetailsDb(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      athleteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}athlete_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}event_id'])!,
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country'])!,
      athleteNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}athlete_number'])!,
    );
  }

  @override
  $AthleteExtraDetailsDbTable createAlias(String alias) {
    return $AthleteExtraDetailsDbTable(attachedDatabase, alias);
  }
}

class AppAthleteExtraDetailsDb extends DataClass
    implements Insertable<AppAthleteExtraDetailsDb> {
  final int id;
  final String athleteId;
  final String name;
  final int eventId;
  final String country;
  final String athleteNumber;
  const AppAthleteExtraDetailsDb(
      {required this.id,
      required this.athleteId,
      required this.name,
      required this.eventId,
      required this.country,
      required this.athleteNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['athlete_id'] = Variable<String>(athleteId);
    map['name'] = Variable<String>(name);
    map['event_id'] = Variable<int>(eventId);
    map['country'] = Variable<String>(country);
    map['athlete_number'] = Variable<String>(athleteNumber);
    return map;
  }

  AthleteExtraDetailsDbCompanion toCompanion(bool nullToAbsent) {
    return AthleteExtraDetailsDbCompanion(
      id: Value(id),
      athleteId: Value(athleteId),
      name: Value(name),
      eventId: Value(eventId),
      country: Value(country),
      athleteNumber: Value(athleteNumber),
    );
  }

  factory AppAthleteExtraDetailsDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppAthleteExtraDetailsDb(
      id: serializer.fromJson<int>(json['id']),
      athleteId: serializer.fromJson<String>(json['athleteId']),
      name: serializer.fromJson<String>(json['name']),
      eventId: serializer.fromJson<int>(json['eventId']),
      country: serializer.fromJson<String>(json['country']),
      athleteNumber: serializer.fromJson<String>(json['athleteNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'athleteId': serializer.toJson<String>(athleteId),
      'name': serializer.toJson<String>(name),
      'eventId': serializer.toJson<int>(eventId),
      'country': serializer.toJson<String>(country),
      'athleteNumber': serializer.toJson<String>(athleteNumber),
    };
  }

  AppAthleteExtraDetailsDb copyWith(
          {int? id,
          String? athleteId,
          String? name,
          int? eventId,
          String? country,
          String? athleteNumber}) =>
      AppAthleteExtraDetailsDb(
        id: id ?? this.id,
        athleteId: athleteId ?? this.athleteId,
        name: name ?? this.name,
        eventId: eventId ?? this.eventId,
        country: country ?? this.country,
        athleteNumber: athleteNumber ?? this.athleteNumber,
      );
  @override
  String toString() {
    return (StringBuffer('AppAthleteExtraDetailsDb(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('name: $name, ')
          ..write('eventId: $eventId, ')
          ..write('country: $country, ')
          ..write('athleteNumber: $athleteNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, athleteId, name, eventId, country, athleteNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppAthleteExtraDetailsDb &&
          other.id == this.id &&
          other.athleteId == this.athleteId &&
          other.name == this.name &&
          other.eventId == this.eventId &&
          other.country == this.country &&
          other.athleteNumber == this.athleteNumber);
}

class AthleteExtraDetailsDbCompanion
    extends UpdateCompanion<AppAthleteExtraDetailsDb> {
  final Value<int> id;
  final Value<String> athleteId;
  final Value<String> name;
  final Value<int> eventId;
  final Value<String> country;
  final Value<String> athleteNumber;
  const AthleteExtraDetailsDbCompanion({
    this.id = const Value.absent(),
    this.athleteId = const Value.absent(),
    this.name = const Value.absent(),
    this.eventId = const Value.absent(),
    this.country = const Value.absent(),
    this.athleteNumber = const Value.absent(),
  });
  AthleteExtraDetailsDbCompanion.insert({
    this.id = const Value.absent(),
    required String athleteId,
    required String name,
    required int eventId,
    required String country,
    required String athleteNumber,
  })  : athleteId = Value(athleteId),
        name = Value(name),
        eventId = Value(eventId),
        country = Value(country),
        athleteNumber = Value(athleteNumber);
  static Insertable<AppAthleteExtraDetailsDb> custom({
    Expression<int>? id,
    Expression<String>? athleteId,
    Expression<String>? name,
    Expression<int>? eventId,
    Expression<String>? country,
    Expression<String>? athleteNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (athleteId != null) 'athlete_id': athleteId,
      if (name != null) 'name': name,
      if (eventId != null) 'event_id': eventId,
      if (country != null) 'country': country,
      if (athleteNumber != null) 'athlete_number': athleteNumber,
    });
  }

  AthleteExtraDetailsDbCompanion copyWith(
      {Value<int>? id,
      Value<String>? athleteId,
      Value<String>? name,
      Value<int>? eventId,
      Value<String>? country,
      Value<String>? athleteNumber}) {
    return AthleteExtraDetailsDbCompanion(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      name: name ?? this.name,
      eventId: eventId ?? this.eventId,
      country: country ?? this.country,
      athleteNumber: athleteNumber ?? this.athleteNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (athleteId.present) {
      map['athlete_id'] = Variable<String>(athleteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (athleteNumber.present) {
      map['athlete_number'] = Variable<String>(athleteNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AthleteExtraDetailsDbCompanion(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('name: $name, ')
          ..write('eventId: $eventId, ')
          ..write('country: $country, ')
          ..write('athleteNumber: $athleteNumber')
          ..write(')'))
        .toString();
  }
}

class $ChatMessageDbTable extends ChatMessageDb
    with TableInfo<$ChatMessageDbTable, AppChatMessageDb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessageDbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, role, content];
  @override
  String get aliasedName => _alias ?? 'chat_message_db';
  @override
  String get actualTableName => 'chat_message_db';
  @override
  VerificationContext validateIntegrity(Insertable<AppChatMessageDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppChatMessageDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppChatMessageDb(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $ChatMessageDbTable createAlias(String alias) {
    return $ChatMessageDbTable(attachedDatabase, alias);
  }
}

class AppChatMessageDb extends DataClass
    implements Insertable<AppChatMessageDb> {
  final int id;
  final String role;
  final String content;
  const AppChatMessageDb(
      {required this.id, required this.role, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    return map;
  }

  ChatMessageDbCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageDbCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
    );
  }

  factory AppChatMessageDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppChatMessageDb(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
    };
  }

  AppChatMessageDb copyWith({int? id, String? role, String? content}) =>
      AppChatMessageDb(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
      );
  @override
  String toString() {
    return (StringBuffer('AppChatMessageDb(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppChatMessageDb &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content);
}

class ChatMessageDbCompanion extends UpdateCompanion<AppChatMessageDb> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  const ChatMessageDbCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
  });
  ChatMessageDbCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
  })  : role = Value(role),
        content = Value(content);
  static Insertable<AppChatMessageDb> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
    });
  }

  ChatMessageDbCompanion copyWith(
      {Value<int>? id, Value<String>? role, Value<String>? content}) {
    return ChatMessageDbCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageDbCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $AthleteDbTable athleteDb = $AthleteDbTable(this);
  late final $AthleteExtraDetailsDbTable athleteExtraDetailsDb =
      $AthleteExtraDetailsDbTable(this);
  late final $ChatMessageDbTable chatMessageDb = $ChatMessageDbTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [athleteDb, athleteExtraDetailsDb, chatMessageDb];
}
