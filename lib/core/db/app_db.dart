import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:evento_core/core/db/models/athlete_extra_details.dart';
import 'package:evento_core/core/db/models/chat_message.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/assistant/assistant_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'models/athlete.dart';

part 'app_db.g.dart';

@DriftDatabase(
  tables: [AthleteDb, AthleteExtraDetailsDb, ChatMessageDb],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1 to
          // version 2
          await m.addColumn(chatMessageDb, chatMessageDb.eventId);
        }
        if (from < 3) {
          // Add a temporary column with the new type
          await customStatement(
              'ALTER TABLE ${athleteDb.actualTableName} ADD COLUMN raceno_temp TEXT');

          // Copy the data from the old column to the new column
          await customStatement(
              'UPDATE ${athleteDb.actualTableName} SET raceno_temp = CAST(raceno AS TEXT)');

          // Drop the old column
          await customStatement(
              'ALTER TABLE ${athleteDb.actualTableName} DROP COLUMN raceno');

          // Rename the new column to match the original column name
          await customStatement(
              'ALTER TABLE ${athleteDb.actualTableName} RENAME COLUMN raceno_temp TO raceno');
        }

        if (from < 6) {
          try {
            // Add a temporary column with the new type
            //await customStatement('ALTER TABLE ${athleteDb.actualTableName} ADD COLUMN disRaceNo TEXT');}
            await customStatement(
                'ALTER TABLE ${athleteDb.actualTableName} ADD COLUMN dis_race_no TEXT');
          } catch (e) {}
        }
        if (from < 7) {
          await customStatement('DELETE FROM ${athleteDb.actualTableName}');
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final databaseFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(databaseFolder.path, 'myapp.sqlite'));
    return NativeDatabase(file);
  });
}

class DatabaseHandler {
  static late AppDatabase _db;

  static void init() async {
    _db = AppDatabase();
  }

  static Future<int> insertAthletes(List<Entrants> entrants) async {
    final followedAthletes = await getAthletes('', true).first;
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    print(' mytest');

    await removeAthletesByEvent(eventId);

    List<AthleteDbCompanion> list = [];
    List<AthleteExtraDetailsDbCompanion> detailsList = [];
    final stopwatch = Stopwatch()..start();
    for (Entrants entrant in entrants) {
      list.add(AthleteDbCompanion.insert(
          athleteId: entrant.id,
          name: entrant.name,
          profileImage: entrant.profileImage,
          raceno: (entrant.number),
          isFollowed: true,
          contestNo: entrant.contest,
          info: entrant.info,
          eventId: eventId,
          extra: entrant.extra,
          disRaceNo: Value(entrant.disRaceNo),
          canFollow: entrant.canFollow,
          searchTag:
              '${entrant.number} ${entrant.name.toLowerCase()} ${entrant.info} ${entrant.extra}'));
      detailsList.addAll(
          await insertAthleteDetails(entrant.athleteDetails ?? [], entrant.id));
    }
    //print(1);
    await Future(() async {
      await _db.batch((batch) {
        batch.insertAll(_db.athleteDb, list);
        batch.insertAll(_db.athleteExtraDetailsDb, detailsList);
      });
    });
    stopwatch.stop();

    //print('Function Execution Time save athletes : ${stopwatch.elapsed}');

    if (followedAthletes.isNotEmpty) {
      for (AppAthleteDb athlete in followedAthletes) {
        updateAthlete(athlete, true);
      }
    }
    return 1;
  }

  static Future<int> insertAthlete(Entrants entrant) async {
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    print(' mytest');

    List<AthleteDbCompanion> list = [];
    List<AthleteExtraDetailsDbCompanion> detailsList = [];
    final stopwatch = Stopwatch()..start();
    //print(1);
    _db.athleteDb.insert().insert(AthleteDbCompanion.insert(
        athleteId: entrant.id,
        name: entrant.name,
        profileImage: entrant.profileImage,
        raceno: (entrant.number),
        isFollowed: true,
        contestNo: entrant.contest,
        info: entrant.info,
        eventId: eventId,
        extra: entrant.extra,
        disRaceNo: Value(entrant.disRaceNo),
        canFollow: entrant.canFollow,
        searchTag:
            '${entrant.number} ${entrant.name.toLowerCase()} ${entrant.info} ${entrant.extra}'));
    _db.athleteExtraDetailsDb.insertAll(
        (await insertAthleteDetails(entrant.athleteDetails ?? [], entrant.id)));
    stopwatch.stop();
    return 1;
  }

  static int getRaceNo(String number) {
    late int? raceNo;
    raceNo = int.tryParse(number);
    raceNo ??= -1;
    return raceNo;
  }

  static Future<List<AthleteExtraDetailsDbCompanion>> insertAthleteDetails(
      List<AthleteDetails> details, String athleteId) async {
    if (details.isEmpty) 1;
    List<AthleteExtraDetailsDbCompanion> list = [];
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    for (AthleteDetails detail in details) {
      list.add(AthleteExtraDetailsDbCompanion.insert(
          name: detail.name,
          athleteId: athleteId,
          eventId: eventId,
          country: detail.country,
          athleteNumber: detail.athleteNumber));
    }
    return list;
  }

  static Stream<List<AppAthleteDb>> getAthletes(
      String searchValue, bool isFollowed,
      {int? offset, int? limit}) async* {
    searchValue = searchValue.toLowerCase();
    Stopwatch stopWatch = Stopwatch();
    stopWatch.start();
    final eventId = Preferences.getInt(AppKeys.eventId, 0);

    var query = _db.athleteDb.select()
      ..where((tbl) => tbl.eventId.equals(eventId))
      ..orderBy([(athlete) => OrderingTerm(expression: athlete.id)]);

    if (searchValue.isNotEmpty) {
      if (isFollowed) {
        query.where((tbl) => tbl.searchTag.equals(searchValue));
      } else {
        query.where((tbl) => tbl.searchTag.contains(searchValue));
      }
    }

    if (isFollowed) {
      query.where((tbl) => tbl.isFollowed.equals(isFollowed));
    }

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    yield* query.watch();
  }

  static Future<List<AppAthleteDb>> getAthletesOnce(
      String searchValue, bool isFollowed,
      {int? offset, int? limit}) async {
    searchValue = searchValue.toLowerCase();
    Stopwatch stopWatch = Stopwatch();
    stopWatch.start();
    final eventId = Preferences.getInt(AppKeys.eventId, 0);

    var query = _db.athleteDb.select()
      ..where((tbl) => tbl.eventId.equals(eventId))
      ..orderBy([(athlete) => OrderingTerm(expression: athlete.id)]);

    if (searchValue.isNotEmpty) {
      if (isFollowed) {
        query.where((tbl) => tbl.searchTag.equals(searchValue));
      } else {
        query.where((tbl) => tbl.searchTag.contains(searchValue));
      }
    }

    if (isFollowed) {
      query.where((tbl) => tbl.isFollowed.equals(isFollowed));
    }

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return await query.get();
  }

  static Stream<AppAthleteDb> getSingleAthlete(String athleteId) async* {
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    Stream<AppAthleteDb> stream = (_db.athleteDb.select()
          ..limit(1)
          ..where((tbl) => tbl.eventId.equals(eventId))
          ..where((tbl) => tbl.athleteId.equals(athleteId)))
        .watchSingle();
    yield* stream;
  }

  static Future<AppAthleteDb?> getSingleAthleteOnce(String athleteId) async {
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    try {
      return await (_db.athleteDb.select()
            ..where((tbl) => tbl.eventId.equals(eventId))
            ..where((tbl) => tbl.athleteId.equals(athleteId)))
          .getSingleOrNull();
    } catch (e) {
      return null;
    }
  }

  static Stream<List<AppAthleteExtraDetailsDb>> getSingleAthleteDetails(
      String athleteId) async* {
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    yield* (_db.athleteExtraDetailsDb.select()
          ..where((tbl) => tbl.eventId.equals(eventId))
          ..where((tbl) => tbl.athleteId.equals(athleteId)))
        .watch();
  }

  static Future<int> updateAthlete(
      AppAthleteDb athlete, bool isFollowed) async {
    final athleteJson = athlete.toJson();
    athleteJson['isFollowed'] = isFollowed;
    return await (_db.athleteDb.update()
          ..where((athleteDb) => athleteDb.eventId.equals(athlete.eventId))
          ..where((athleteDb) => athleteDb.athleteId.equals(athlete.athleteId)))
        .write(AppAthleteDb.fromJson(athleteJson));
  }

  static Future<int> removeAllAthletes() async {
    return await _db.delete(_db.athleteDb).go();
  }

  static Future<int> removeAthlete(String id) async {
    removeAthleteDetails(id);
    return await (_db.delete(_db.athleteDb)
          ..where((tbl) => tbl.athleteId.equals(id)))
        .go();
  }

  static Future<int> removeAthletesByEvent(int eventId) async {
    removeAthletesDetailsByEvent(eventId);
    return await (_db.delete(_db.athleteDb)
          ..where((tbl) => tbl.eventId.equals(eventId)))
        .go();
  }

  static Future<int> removeAthletesDetailsByEvent(int eventId) async {
    return await (_db.delete(_db.athleteExtraDetailsDb)
          ..where((tbl) => tbl.eventId.equals(eventId)))
        .go();
  }

  static Future<int> removeAthleteDetails(String id) async {
    return await (_db.delete(_db.athleteExtraDetailsDb)
          ..where((tbl) => tbl.athleteId.equals(id)))
        .go();
  }

  static Future<int> insertChatMessage(ChatMessageM message) {
    return _db.into(_db.chatMessageDb).insert(ChatMessageDbCompanion.insert(
        role: message.role!,
        content: message.content!,
        eventId: Value(Preferences.getInt(AppKeys.eventId, 0).toString())));
  }

  static Future<List<ChatMessageM>> getAllChatMessages() async {
    var eventId = Preferences.getInt(AppKeys.eventId, 0).toString();
    final messages = await (_db.chatMessageDb.select()
          ..where((tbl) => tbl.eventId.equals(eventId)))
        .get();
    return messages
        .map((message) => ChatMessageM.fromJson(message.toJson()))
        .toList();
  }

  static Future<int> removeAllChatMessages() async {
    return await (_db.delete(_db.chatMessageDb)).go();
  }
}
