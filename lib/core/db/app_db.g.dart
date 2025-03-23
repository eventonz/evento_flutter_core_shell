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
  static const VerificationMeta _disRaceNoMeta =
      const VerificationMeta('disRaceNo');
  @override
  late final GeneratedColumn<String> disRaceNo = GeneratedColumn<String>(
      'dis_race_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  late final GeneratedColumn<String> raceno = GeneratedColumn<String>(
      'raceno', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _countryMeta =
      const VerificationMeta('country');
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
      'country', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        athleteId,
        canFollow,
        isFollowed,
        name,
        disRaceNo,
        extra,
        profileImage,
        raceno,
        eventId,
        info,
        contestNo,
        searchTag,
        country
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'athlete_db';
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
    if (data.containsKey('dis_race_no')) {
      context.handle(
          _disRaceNoMeta,
          disRaceNo.isAcceptableOrUnknown(
              data['dis_race_no']!, _disRaceNoMeta));
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
    if (data.containsKey('country')) {
      context.handle(_countryMeta,
          country.isAcceptableOrUnknown(data['country']!, _countryMeta));
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
      disRaceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dis_race_no']),
      extra: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra'])!,
      profileImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_image'])!,
      raceno: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raceno'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}event_id'])!,
      info: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}info'])!,
      contestNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}contest_no'])!,
      searchTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_tag'])!,
      country: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country']),
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
  final String? disRaceNo;
  final String extra;
  final String profileImage;
  final String raceno;
  final int eventId;
  final String info;
  final int contestNo;
  final String searchTag;
  final String? country;
  const AppAthleteDb(
      {required this.id,
      required this.athleteId,
      required this.canFollow,
      required this.isFollowed,
      required this.name,
      this.disRaceNo,
      required this.extra,
      required this.profileImage,
      required this.raceno,
      required this.eventId,
      required this.info,
      required this.contestNo,
      required this.searchTag,
      this.country});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['athlete_id'] = Variable<String>(athleteId);
    map['can_follow'] = Variable<bool>(canFollow);
    map['is_followed'] = Variable<bool>(isFollowed);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || disRaceNo != null) {
      map['dis_race_no'] = Variable<String>(disRaceNo);
    }
    map['extra'] = Variable<String>(extra);
    map['profile_image'] = Variable<String>(profileImage);
    map['raceno'] = Variable<String>(raceno);
    map['event_id'] = Variable<int>(eventId);
    map['info'] = Variable<String>(info);
    map['contest_no'] = Variable<int>(contestNo);
    map['search_tag'] = Variable<String>(searchTag);
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    return map;
  }

  AthleteDbCompanion toCompanion(bool nullToAbsent) {
    return AthleteDbCompanion(
      id: Value(id),
      athleteId: Value(athleteId),
      canFollow: Value(canFollow),
      isFollowed: Value(isFollowed),
      name: Value(name),
      disRaceNo: disRaceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(disRaceNo),
      extra: Value(extra),
      profileImage: Value(profileImage),
      raceno: Value(raceno),
      eventId: Value(eventId),
      info: Value(info),
      contestNo: Value(contestNo),
      searchTag: Value(searchTag),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
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
      disRaceNo: serializer.fromJson<String?>(json['disRaceNo']),
      extra: serializer.fromJson<String>(json['extra']),
      profileImage: serializer.fromJson<String>(json['profileImage']),
      raceno: serializer.fromJson<String>(json['raceno']),
      eventId: serializer.fromJson<int>(json['eventId']),
      info: serializer.fromJson<String>(json['info']),
      contestNo: serializer.fromJson<int>(json['contestNo']),
      searchTag: serializer.fromJson<String>(json['searchTag']),
      country: serializer.fromJson<String?>(json['country']),
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
      'disRaceNo': serializer.toJson<String?>(disRaceNo),
      'extra': serializer.toJson<String>(extra),
      'profileImage': serializer.toJson<String>(profileImage),
      'raceno': serializer.toJson<String>(raceno),
      'eventId': serializer.toJson<int>(eventId),
      'info': serializer.toJson<String>(info),
      'contestNo': serializer.toJson<int>(contestNo),
      'searchTag': serializer.toJson<String>(searchTag),
      'country': serializer.toJson<String?>(country),
    };
  }

  AppAthleteDb copyWith(
          {int? id,
          String? athleteId,
          bool? canFollow,
          bool? isFollowed,
          String? name,
          Value<String?> disRaceNo = const Value.absent(),
          String? extra,
          String? profileImage,
          String? raceno,
          int? eventId,
          String? info,
          int? contestNo,
          String? searchTag,
          Value<String?> country = const Value.absent()}) =>
      AppAthleteDb(
        id: id ?? this.id,
        athleteId: athleteId ?? this.athleteId,
        canFollow: canFollow ?? this.canFollow,
        isFollowed: isFollowed ?? this.isFollowed,
        name: name ?? this.name,
        disRaceNo: disRaceNo.present ? disRaceNo.value : this.disRaceNo,
        extra: extra ?? this.extra,
        profileImage: profileImage ?? this.profileImage,
        raceno: raceno ?? this.raceno,
        eventId: eventId ?? this.eventId,
        info: info ?? this.info,
        contestNo: contestNo ?? this.contestNo,
        searchTag: searchTag ?? this.searchTag,
        country: country.present ? country.value : this.country,
      );
  AppAthleteDb copyWithCompanion(AthleteDbCompanion data) {
    return AppAthleteDb(
      id: data.id.present ? data.id.value : this.id,
      athleteId: data.athleteId.present ? data.athleteId.value : this.athleteId,
      canFollow: data.canFollow.present ? data.canFollow.value : this.canFollow,
      isFollowed:
          data.isFollowed.present ? data.isFollowed.value : this.isFollowed,
      name: data.name.present ? data.name.value : this.name,
      disRaceNo: data.disRaceNo.present ? data.disRaceNo.value : this.disRaceNo,
      extra: data.extra.present ? data.extra.value : this.extra,
      profileImage: data.profileImage.present
          ? data.profileImage.value
          : this.profileImage,
      raceno: data.raceno.present ? data.raceno.value : this.raceno,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      info: data.info.present ? data.info.value : this.info,
      contestNo: data.contestNo.present ? data.contestNo.value : this.contestNo,
      searchTag: data.searchTag.present ? data.searchTag.value : this.searchTag,
      country: data.country.present ? data.country.value : this.country,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppAthleteDb(')
          ..write('id: $id, ')
          ..write('athleteId: $athleteId, ')
          ..write('canFollow: $canFollow, ')
          ..write('isFollowed: $isFollowed, ')
          ..write('name: $name, ')
          ..write('disRaceNo: $disRaceNo, ')
          ..write('extra: $extra, ')
          ..write('profileImage: $profileImage, ')
          ..write('raceno: $raceno, ')
          ..write('eventId: $eventId, ')
          ..write('info: $info, ')
          ..write('contestNo: $contestNo, ')
          ..write('searchTag: $searchTag, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      athleteId,
      canFollow,
      isFollowed,
      name,
      disRaceNo,
      extra,
      profileImage,
      raceno,
      eventId,
      info,
      contestNo,
      searchTag,
      country);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppAthleteDb &&
          other.id == this.id &&
          other.athleteId == this.athleteId &&
          other.canFollow == this.canFollow &&
          other.isFollowed == this.isFollowed &&
          other.name == this.name &&
          other.disRaceNo == this.disRaceNo &&
          other.extra == this.extra &&
          other.profileImage == this.profileImage &&
          other.raceno == this.raceno &&
          other.eventId == this.eventId &&
          other.info == this.info &&
          other.contestNo == this.contestNo &&
          other.searchTag == this.searchTag &&
          other.country == this.country);
}

class AthleteDbCompanion extends UpdateCompanion<AppAthleteDb> {
  final Value<int> id;
  final Value<String> athleteId;
  final Value<bool> canFollow;
  final Value<bool> isFollowed;
  final Value<String> name;
  final Value<String?> disRaceNo;
  final Value<String> extra;
  final Value<String> profileImage;
  final Value<String> raceno;
  final Value<int> eventId;
  final Value<String> info;
  final Value<int> contestNo;
  final Value<String> searchTag;
  final Value<String?> country;
  const AthleteDbCompanion({
    this.id = const Value.absent(),
    this.athleteId = const Value.absent(),
    this.canFollow = const Value.absent(),
    this.isFollowed = const Value.absent(),
    this.name = const Value.absent(),
    this.disRaceNo = const Value.absent(),
    this.extra = const Value.absent(),
    this.profileImage = const Value.absent(),
    this.raceno = const Value.absent(),
    this.eventId = const Value.absent(),
    this.info = const Value.absent(),
    this.contestNo = const Value.absent(),
    this.searchTag = const Value.absent(),
    this.country = const Value.absent(),
  });
  AthleteDbCompanion.insert({
    this.id = const Value.absent(),
    required String athleteId,
    required bool canFollow,
    required bool isFollowed,
    required String name,
    this.disRaceNo = const Value.absent(),
    required String extra,
    required String profileImage,
    required String raceno,
    required int eventId,
    required String info,
    required int contestNo,
    required String searchTag,
    this.country = const Value.absent(),
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
    Expression<String>? disRaceNo,
    Expression<String>? extra,
    Expression<String>? profileImage,
    Expression<String>? raceno,
    Expression<int>? eventId,
    Expression<String>? info,
    Expression<int>? contestNo,
    Expression<String>? searchTag,
    Expression<String>? country,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (athleteId != null) 'athlete_id': athleteId,
      if (canFollow != null) 'can_follow': canFollow,
      if (isFollowed != null) 'is_followed': isFollowed,
      if (name != null) 'name': name,
      if (disRaceNo != null) 'dis_race_no': disRaceNo,
      if (extra != null) 'extra': extra,
      if (profileImage != null) 'profile_image': profileImage,
      if (raceno != null) 'raceno': raceno,
      if (eventId != null) 'event_id': eventId,
      if (info != null) 'info': info,
      if (contestNo != null) 'contest_no': contestNo,
      if (searchTag != null) 'search_tag': searchTag,
      if (country != null) 'country': country,
    });
  }

  AthleteDbCompanion copyWith(
      {Value<int>? id,
      Value<String>? athleteId,
      Value<bool>? canFollow,
      Value<bool>? isFollowed,
      Value<String>? name,
      Value<String?>? disRaceNo,
      Value<String>? extra,
      Value<String>? profileImage,
      Value<String>? raceno,
      Value<int>? eventId,
      Value<String>? info,
      Value<int>? contestNo,
      Value<String>? searchTag,
      Value<String?>? country}) {
    return AthleteDbCompanion(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      canFollow: canFollow ?? this.canFollow,
      isFollowed: isFollowed ?? this.isFollowed,
      name: name ?? this.name,
      disRaceNo: disRaceNo ?? this.disRaceNo,
      extra: extra ?? this.extra,
      profileImage: profileImage ?? this.profileImage,
      raceno: raceno ?? this.raceno,
      eventId: eventId ?? this.eventId,
      info: info ?? this.info,
      contestNo: contestNo ?? this.contestNo,
      searchTag: searchTag ?? this.searchTag,
      country: country ?? this.country,
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
    if (disRaceNo.present) {
      map['dis_race_no'] = Variable<String>(disRaceNo.value);
    }
    if (extra.present) {
      map['extra'] = Variable<String>(extra.value);
    }
    if (profileImage.present) {
      map['profile_image'] = Variable<String>(profileImage.value);
    }
    if (raceno.present) {
      map['raceno'] = Variable<String>(raceno.value);
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
    if (country.present) {
      map['country'] = Variable<String>(country.value);
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
          ..write('disRaceNo: $disRaceNo, ')
          ..write('extra: $extra, ')
          ..write('profileImage: $profileImage, ')
          ..write('raceno: $raceno, ')
          ..write('eventId: $eventId, ')
          ..write('info: $info, ')
          ..write('contestNo: $contestNo, ')
          ..write('searchTag: $searchTag, ')
          ..write('country: $country')
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
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'athlete_extra_details_db';
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
  AppAthleteExtraDetailsDb copyWithCompanion(
      AthleteExtraDetailsDbCompanion data) {
    return AppAthleteExtraDetailsDb(
      id: data.id.present ? data.id.value : this.id,
      athleteId: data.athleteId.present ? data.athleteId.value : this.athleteId,
      name: data.name.present ? data.name.value : this.name,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      country: data.country.present ? data.country.value : this.country,
      athleteNumber: data.athleteNumber.present
          ? data.athleteNumber.value
          : this.athleteNumber,
    );
  }

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
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, role, eventId, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message_db';
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
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
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
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id']),
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
  final String? eventId;
  final String content;
  const AppChatMessageDb(
      {required this.id,
      required this.role,
      this.eventId,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || eventId != null) {
      map['event_id'] = Variable<String>(eventId);
    }
    map['content'] = Variable<String>(content);
    return map;
  }

  ChatMessageDbCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageDbCompanion(
      id: Value(id),
      role: Value(role),
      eventId: eventId == null && nullToAbsent
          ? const Value.absent()
          : Value(eventId),
      content: Value(content),
    );
  }

  factory AppChatMessageDb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppChatMessageDb(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      eventId: serializer.fromJson<String?>(json['eventId']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'eventId': serializer.toJson<String?>(eventId),
      'content': serializer.toJson<String>(content),
    };
  }

  AppChatMessageDb copyWith(
          {int? id,
          String? role,
          Value<String?> eventId = const Value.absent(),
          String? content}) =>
      AppChatMessageDb(
        id: id ?? this.id,
        role: role ?? this.role,
        eventId: eventId.present ? eventId.value : this.eventId,
        content: content ?? this.content,
      );
  AppChatMessageDb copyWithCompanion(ChatMessageDbCompanion data) {
    return AppChatMessageDb(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppChatMessageDb(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('eventId: $eventId, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, eventId, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppChatMessageDb &&
          other.id == this.id &&
          other.role == this.role &&
          other.eventId == this.eventId &&
          other.content == this.content);
}

class ChatMessageDbCompanion extends UpdateCompanion<AppChatMessageDb> {
  final Value<int> id;
  final Value<String> role;
  final Value<String?> eventId;
  final Value<String> content;
  const ChatMessageDbCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.eventId = const Value.absent(),
    this.content = const Value.absent(),
  });
  ChatMessageDbCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    this.eventId = const Value.absent(),
    required String content,
  })  : role = Value(role),
        content = Value(content);
  static Insertable<AppChatMessageDb> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? eventId,
    Expression<String>? content,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (eventId != null) 'event_id': eventId,
      if (content != null) 'content': content,
    });
  }

  ChatMessageDbCompanion copyWith(
      {Value<int>? id,
      Value<String>? role,
      Value<String?>? eventId,
      Value<String>? content}) {
    return ChatMessageDbCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      eventId: eventId ?? this.eventId,
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
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
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
          ..write('eventId: $eventId, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
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

typedef $$AthleteDbTableCreateCompanionBuilder = AthleteDbCompanion Function({
  Value<int> id,
  required String athleteId,
  required bool canFollow,
  required bool isFollowed,
  required String name,
  Value<String?> disRaceNo,
  required String extra,
  required String profileImage,
  required String raceno,
  required int eventId,
  required String info,
  required int contestNo,
  required String searchTag,
  Value<String?> country,
});
typedef $$AthleteDbTableUpdateCompanionBuilder = AthleteDbCompanion Function({
  Value<int> id,
  Value<String> athleteId,
  Value<bool> canFollow,
  Value<bool> isFollowed,
  Value<String> name,
  Value<String?> disRaceNo,
  Value<String> extra,
  Value<String> profileImage,
  Value<String> raceno,
  Value<int> eventId,
  Value<String> info,
  Value<int> contestNo,
  Value<String> searchTag,
  Value<String?> country,
});

class $$AthleteDbTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AthleteDbTable> {
  $$AthleteDbTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get athleteId => $state.composableBuilder(
      column: $state.table.athleteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get canFollow => $state.composableBuilder(
      column: $state.table.canFollow,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isFollowed => $state.composableBuilder(
      column: $state.table.isFollowed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get disRaceNo => $state.composableBuilder(
      column: $state.table.disRaceNo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get extra => $state.composableBuilder(
      column: $state.table.extra,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileImage => $state.composableBuilder(
      column: $state.table.profileImage,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get raceno => $state.composableBuilder(
      column: $state.table.raceno,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get info => $state.composableBuilder(
      column: $state.table.info,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get contestNo => $state.composableBuilder(
      column: $state.table.contestNo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get searchTag => $state.composableBuilder(
      column: $state.table.searchTag,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get country => $state.composableBuilder(
      column: $state.table.country,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AthleteDbTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AthleteDbTable> {
  $$AthleteDbTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get athleteId => $state.composableBuilder(
      column: $state.table.athleteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get canFollow => $state.composableBuilder(
      column: $state.table.canFollow,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isFollowed => $state.composableBuilder(
      column: $state.table.isFollowed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get disRaceNo => $state.composableBuilder(
      column: $state.table.disRaceNo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get extra => $state.composableBuilder(
      column: $state.table.extra,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileImage => $state.composableBuilder(
      column: $state.table.profileImage,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get raceno => $state.composableBuilder(
      column: $state.table.raceno,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get info => $state.composableBuilder(
      column: $state.table.info,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get contestNo => $state.composableBuilder(
      column: $state.table.contestNo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get searchTag => $state.composableBuilder(
      column: $state.table.searchTag,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get country => $state.composableBuilder(
      column: $state.table.country,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$AthleteDbTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AthleteDbTable,
    AppAthleteDb,
    $$AthleteDbTableFilterComposer,
    $$AthleteDbTableOrderingComposer,
    $$AthleteDbTableCreateCompanionBuilder,
    $$AthleteDbTableUpdateCompanionBuilder,
    (
      AppAthleteDb,
      BaseReferences<_$AppDatabase, $AthleteDbTable, AppAthleteDb>
    ),
    AppAthleteDb,
    PrefetchHooks Function()> {
  $$AthleteDbTableTableManager(_$AppDatabase db, $AthleteDbTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AthleteDbTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AthleteDbTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> athleteId = const Value.absent(),
            Value<bool> canFollow = const Value.absent(),
            Value<bool> isFollowed = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> disRaceNo = const Value.absent(),
            Value<String> extra = const Value.absent(),
            Value<String> profileImage = const Value.absent(),
            Value<String> raceno = const Value.absent(),
            Value<int> eventId = const Value.absent(),
            Value<String> info = const Value.absent(),
            Value<int> contestNo = const Value.absent(),
            Value<String> searchTag = const Value.absent(),
            Value<String?> country = const Value.absent(),
          }) =>
              AthleteDbCompanion(
            id: id,
            athleteId: athleteId,
            canFollow: canFollow,
            isFollowed: isFollowed,
            name: name,
            disRaceNo: disRaceNo,
            extra: extra,
            profileImage: profileImage,
            raceno: raceno,
            eventId: eventId,
            info: info,
            contestNo: contestNo,
            searchTag: searchTag,
            country: country,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String athleteId,
            required bool canFollow,
            required bool isFollowed,
            required String name,
            Value<String?> disRaceNo = const Value.absent(),
            required String extra,
            required String profileImage,
            required String raceno,
            required int eventId,
            required String info,
            required int contestNo,
            required String searchTag,
            Value<String?> country = const Value.absent(),
          }) =>
              AthleteDbCompanion.insert(
            id: id,
            athleteId: athleteId,
            canFollow: canFollow,
            isFollowed: isFollowed,
            name: name,
            disRaceNo: disRaceNo,
            extra: extra,
            profileImage: profileImage,
            raceno: raceno,
            eventId: eventId,
            info: info,
            contestNo: contestNo,
            searchTag: searchTag,
            country: country,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AthleteDbTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AthleteDbTable,
    AppAthleteDb,
    $$AthleteDbTableFilterComposer,
    $$AthleteDbTableOrderingComposer,
    $$AthleteDbTableCreateCompanionBuilder,
    $$AthleteDbTableUpdateCompanionBuilder,
    (
      AppAthleteDb,
      BaseReferences<_$AppDatabase, $AthleteDbTable, AppAthleteDb>
    ),
    AppAthleteDb,
    PrefetchHooks Function()>;
typedef $$AthleteExtraDetailsDbTableCreateCompanionBuilder
    = AthleteExtraDetailsDbCompanion Function({
  Value<int> id,
  required String athleteId,
  required String name,
  required int eventId,
  required String country,
  required String athleteNumber,
});
typedef $$AthleteExtraDetailsDbTableUpdateCompanionBuilder
    = AthleteExtraDetailsDbCompanion Function({
  Value<int> id,
  Value<String> athleteId,
  Value<String> name,
  Value<int> eventId,
  Value<String> country,
  Value<String> athleteNumber,
});

class $$AthleteExtraDetailsDbTableFilterComposer
    extends FilterComposer<_$AppDatabase, $AthleteExtraDetailsDbTable> {
  $$AthleteExtraDetailsDbTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get athleteId => $state.composableBuilder(
      column: $state.table.athleteId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get country => $state.composableBuilder(
      column: $state.table.country,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get athleteNumber => $state.composableBuilder(
      column: $state.table.athleteNumber,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AthleteExtraDetailsDbTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $AthleteExtraDetailsDbTable> {
  $$AthleteExtraDetailsDbTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get athleteId => $state.composableBuilder(
      column: $state.table.athleteId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get country => $state.composableBuilder(
      column: $state.table.country,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get athleteNumber => $state.composableBuilder(
      column: $state.table.athleteNumber,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$AthleteExtraDetailsDbTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AthleteExtraDetailsDbTable,
    AppAthleteExtraDetailsDb,
    $$AthleteExtraDetailsDbTableFilterComposer,
    $$AthleteExtraDetailsDbTableOrderingComposer,
    $$AthleteExtraDetailsDbTableCreateCompanionBuilder,
    $$AthleteExtraDetailsDbTableUpdateCompanionBuilder,
    (
      AppAthleteExtraDetailsDb,
      BaseReferences<_$AppDatabase, $AthleteExtraDetailsDbTable,
          AppAthleteExtraDetailsDb>
    ),
    AppAthleteExtraDetailsDb,
    PrefetchHooks Function()> {
  $$AthleteExtraDetailsDbTableTableManager(
      _$AppDatabase db, $AthleteExtraDetailsDbTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$AthleteExtraDetailsDbTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$AthleteExtraDetailsDbTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> athleteId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> eventId = const Value.absent(),
            Value<String> country = const Value.absent(),
            Value<String> athleteNumber = const Value.absent(),
          }) =>
              AthleteExtraDetailsDbCompanion(
            id: id,
            athleteId: athleteId,
            name: name,
            eventId: eventId,
            country: country,
            athleteNumber: athleteNumber,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String athleteId,
            required String name,
            required int eventId,
            required String country,
            required String athleteNumber,
          }) =>
              AthleteExtraDetailsDbCompanion.insert(
            id: id,
            athleteId: athleteId,
            name: name,
            eventId: eventId,
            country: country,
            athleteNumber: athleteNumber,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AthleteExtraDetailsDbTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AthleteExtraDetailsDbTable,
        AppAthleteExtraDetailsDb,
        $$AthleteExtraDetailsDbTableFilterComposer,
        $$AthleteExtraDetailsDbTableOrderingComposer,
        $$AthleteExtraDetailsDbTableCreateCompanionBuilder,
        $$AthleteExtraDetailsDbTableUpdateCompanionBuilder,
        (
          AppAthleteExtraDetailsDb,
          BaseReferences<_$AppDatabase, $AthleteExtraDetailsDbTable,
              AppAthleteExtraDetailsDb>
        ),
        AppAthleteExtraDetailsDb,
        PrefetchHooks Function()>;
typedef $$ChatMessageDbTableCreateCompanionBuilder = ChatMessageDbCompanion
    Function({
  Value<int> id,
  required String role,
  Value<String?> eventId,
  required String content,
});
typedef $$ChatMessageDbTableUpdateCompanionBuilder = ChatMessageDbCompanion
    Function({
  Value<int> id,
  Value<String> role,
  Value<String?> eventId,
  Value<String> content,
});

class $$ChatMessageDbTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ChatMessageDbTable> {
  $$ChatMessageDbTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ChatMessageDbTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ChatMessageDbTable> {
  $$ChatMessageDbTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get role => $state.composableBuilder(
      column: $state.table.role,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$ChatMessageDbTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessageDbTable,
    AppChatMessageDb,
    $$ChatMessageDbTableFilterComposer,
    $$ChatMessageDbTableOrderingComposer,
    $$ChatMessageDbTableCreateCompanionBuilder,
    $$ChatMessageDbTableUpdateCompanionBuilder,
    (
      AppChatMessageDb,
      BaseReferences<_$AppDatabase, $ChatMessageDbTable, AppChatMessageDb>
    ),
    AppChatMessageDb,
    PrefetchHooks Function()> {
  $$ChatMessageDbTableTableManager(_$AppDatabase db, $ChatMessageDbTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ChatMessageDbTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ChatMessageDbTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> eventId = const Value.absent(),
            Value<String> content = const Value.absent(),
          }) =>
              ChatMessageDbCompanion(
            id: id,
            role: role,
            eventId: eventId,
            content: content,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String role,
            Value<String?> eventId = const Value.absent(),
            required String content,
          }) =>
              ChatMessageDbCompanion.insert(
            id: id,
            role: role,
            eventId: eventId,
            content: content,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessageDbTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessageDbTable,
    AppChatMessageDb,
    $$ChatMessageDbTableFilterComposer,
    $$ChatMessageDbTableOrderingComposer,
    $$ChatMessageDbTableCreateCompanionBuilder,
    $$ChatMessageDbTableUpdateCompanionBuilder,
    (
      AppChatMessageDb,
      BaseReferences<_$AppDatabase, $ChatMessageDbTable, AppChatMessageDb>
    ),
    AppChatMessageDb,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AthleteDbTableTableManager get athleteDb =>
      $$AthleteDbTableTableManager(_db, _db.athleteDb);
  $$AthleteExtraDetailsDbTableTableManager get athleteExtraDetailsDb =>
      $$AthleteExtraDetailsDbTableTableManager(_db, _db.athleteExtraDetailsDb);
  $$ChatMessageDbTableTableManager get chatMessageDb =>
      $$ChatMessageDbTableTableManager(_db, _db.chatMessageDb);
}
