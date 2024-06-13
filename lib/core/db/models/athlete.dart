import 'package:drift/drift.dart';

@DataClassName('AppAthleteDb')
class AthleteDb extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get athleteId => text()();
  BoolColumn get canFollow => boolean()();
  BoolColumn get isFollowed => boolean()();
  TextColumn get name => text()();
  TextColumn get extra => text()();
  TextColumn get profileImage => text()();
  TextColumn get raceno => text()();
  IntColumn get eventId => integer()();
  TextColumn get info => text()();
  IntColumn get contestNo => integer()();
  TextColumn get searchTag => text()();
}
