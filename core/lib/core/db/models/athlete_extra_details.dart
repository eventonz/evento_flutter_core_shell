import 'package:drift/drift.dart';

@DataClassName('AppAthleteExtraDetailsDb')
class AthleteExtraDetailsDb extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get athleteId => text()();
  TextColumn get name => text()();
  IntColumn get eventId => integer()();
  TextColumn get country => text()();
  TextColumn get athleteNumber => text()();
}
