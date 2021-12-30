import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sql_constants.dart';

class SqfLiteRepository {
  Database? dbInstance;

  Future<Database> initializeLocalStorage() async {
    return await openDatabase(
      join(await getDatabasesPath(), '$notificationTableName.db'),
      onCreate: (db, version) {
        db.execute(notificationTableCreationQuery);
      },
      version: sqlVersion,
    );
  }

  Future checkIfInitialized() async {
    dbInstance ??= await initializeLocalStorage();
  }

  Future<bool> insertDataTable(
    String tableName,
    List<Map<String, dynamic>> dataRows, {
    bool needDeletion = false,
  }) async {
    try {
      await checkIfInitialized();
      var batch = dbInstance!.batch();
      if (needDeletion) {
        batch.delete(tableName);
      }

      for (var dataRow in dataRows) {
        batch.insert(tableName, dataRow);
      }

      await batch.commit();
      return true;
    } on Exception {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> queryTable(
    String tableName, {
    String? whereQuery,
    List<String>? whereArgs,
  }) async {
    try {
      await checkIfInitialized();
      return await dbInstance!.query(
        tableName,
        where: whereQuery,
        whereArgs: whereArgs,
      );
    } on Exception {
      return [];
    }
  }
}
