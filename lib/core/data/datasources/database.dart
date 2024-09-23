import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
//import 'package:drift_flutter/drift_flutter.dart';
//import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().unique().withLength(min: 6, max: 32)();
  TextColumn get description => text().named('body')();
  IntColumn get category => integer().nullable().references(TodoCategory, #id)();
  IntColumn get priority => integer().nullable().references(TodoPriority, #id)();
  TextColumn get comment => text().nullable()();
}

class TodoCategory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().unique()();
}

class TodoPriority extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().unique()();
}

@DriftDatabase(tables: [TodoItems, TodoCategory, TodoPriority])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m,old,now) async {
        if(old < 2){
          await m.create(todoPriority);
        }
        if(old < 3){
          await m.addColumn(todoItems, todoItems.priority);
        }
        if(old < 4){
          // удаление столбца с датой создания
          // переименование столбца content в description
          await m.alterTable(TableMigration(todoItems));
        }
        if(old < 5){
          await m.addColumn(todoItems, todoItems.comment);
        }
        if(old < 6){
          await m.alterTable(TableMigration(todoItems, columnTransformer: {
            todoItems.comment : todoItems.comment.cast<String>()
          }));
        }
      },
      beforeOpen: (d) async {

      }
    );
  }


  Future<List<TodoItem>> get allTodoItems => select(todoItems).get();
  Future<List<TodoCategoryData>> get allTodoCategory => select(todoCategory).get();
  Future<List<TodoPriorityData>> get allTodoPriority => select(todoPriority).get();

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }
      final cachebase = (await getTemporaryDirectory()).path;
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }
}
