import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:evento_core/core/db/models/athlete_extra_details.dart';
import 'package:evento_core/core/db/models/chat_message.dart';
import 'package:evento_core/core/models/athlete.dart';
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
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
    await removeAthletesByEvent(eventId);
    for (Entrants entrant in entrants) {
      await Future(() async {
        await insertAthleteDetails(entrant.athleteDetails ?? [], entrant.id);
        _db.into(_db.athleteDb).insert(AthleteDbCompanion.insert(
            athleteId: entrant.id,
            name: entrant.name,
            profileImage: entrant.profileImage,
            raceno: getRaceNo(entrant.number),
            isFollowed: false,
            contestNo: entrant.contest,
            info: entrant.info,
            eventId: eventId,
            extra: entrant.extra,
            canFollow: entrant.canFollow,
            searchTag:
                '${entrant.number} ${entrant.name.toLowerCase()} ${entrant.info} ${entrant.extra}'));
      });
    }
    if (followedAthletes.isNotEmpty) {
      for (AppAthleteDb athlete in followedAthletes) {
        updateAthlete(athlete, true);
      }
    }
    return 1;
  }

  static int getRaceNo(String number) {
    late int? raceNo;
    raceNo = int.tryParse(number);
    raceNo ??= -1;
    return raceNo;
  }

  static Future<int> insertAthleteDetails(
      List<AthleteDetails> details, String athleteId) async {
    if (details.isEmpty) 1;
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    for (AthleteDetails detail in details) {
      await _db.into(_db.athleteExtraDetailsDb).insert(
          AthleteExtraDetailsDbCompanion.insert(
              name: detail.name,
              athleteId: athleteId,
              eventId: eventId,
              country: detail.country,
              athleteNumber: detail.athleteNumber));
    }
    return 1;
  }

  static Stream<List<AppAthleteDb>> getAthletes(
      String searchValue, bool isFollowed) async* {
    searchValue = searchValue.toLowerCase();
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    if (searchValue.isEmpty) {
      if (isFollowed) {
        yield* (_db.athleteDb.select()
              ..where((tbl) => tbl.isFollowed.equals(isFollowed))
              ..where((tbl) => tbl.isFollowed.equals(isFollowed))
              ..where((tbl) => tbl.eventId.equals(eventId))
              ..orderBy(
                  [(athlete) => OrderingTerm(expression: athlete.raceno)]))
            .watch();
      }
      yield* (_db.athleteDb.select()
            ..where((tbl) => tbl.eventId.equals(eventId))
            ..orderBy([(athlete) => OrderingTerm(expression: athlete.raceno)]))
          .watch();
    } else {
      if (isFollowed) {
        yield* (_db.athleteDb.select()
              ..where((tbl) => tbl.searchTag.equals(searchValue))
              ..where((tbl) => tbl.isFollowed.equals(isFollowed))
              ..where((tbl) => tbl.eventId.equals(eventId))
              ..orderBy(
                  [(athlete) => OrderingTerm(expression: athlete.raceno)]))
            .watch();
      }
      yield* (_db.athleteDb.select()
            ..where((tbl) => tbl.searchTag.contains(searchValue))
            ..where((tbl) => tbl.eventId.equals(eventId))
            ..orderBy([(athlete) => OrderingTerm(expression: athlete.raceno)]))
          .watch();
    }
  }

  static Stream<AppAthleteDb> getSingleAthlete(String athleteId) async* {
    final eventId = Preferences.getInt(AppKeys.eventId, 0);
    yield* (_db.athleteDb.select()
          ..where((tbl) => tbl.eventId.equals(eventId))
          ..where((tbl) => tbl.athleteId.equals(athleteId)))
        .watchSingle();
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

  static Future<int> insertChatMessage(ChatMessageM message) {
    return _db.into(_db.chatMessageDb).insert(ChatMessageDbCompanion.insert(
        role: message.role!, content: message.content!));
  }

  static Future<List<ChatMessageM>> getAllChatMessages() async {
    final messages = await _db.chatMessageDb.select().get();
    return messages
        .map((message) => ChatMessageM.fromJson(message.toJson()))
        .toList();
  }

  static Future<int> removeAllChatMessages() async {
    return await (_db.delete(_db.chatMessageDb)).go();
  }
}
