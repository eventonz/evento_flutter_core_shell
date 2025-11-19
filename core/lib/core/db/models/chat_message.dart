import 'package:drift/drift.dart';

@DataClassName('AppChatMessageDb')
class ChatMessageDb extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()();
  TextColumn get eventId => text().nullable()();
  TextColumn get content => text()();
}
