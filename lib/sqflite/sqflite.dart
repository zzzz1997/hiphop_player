import 'dart:async';

import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:sqflite/sqflite.dart';

///
/// 数据库工具类
///
/// @author zzzz1997
/// @created_time 20200914
///
class SqfliteUtil {
  // 数据库
  static Database database;

  ///
  /// 初始化
  ///
  static Future<Database> init() async {
    var path = await getDatabasesPath();
    database = await openDatabase(
      '$path/hiphop_player.db',
      version: 2,
      singleInstance: false,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
    return database;
  }

  ///
  /// 数据库创建事件
  ///
  static FutureOr<void> _onCreate(Database db, int version) async {
    await MusicItemProvider.createTable(db);
  }

  ///
  /// 数据库更新事件
  ///
  static FutureOr<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    if (oldVersion == 1) {
      batch.execute('alter table ta_person add fire text');
    } else if (oldVersion == 2) {
      batch.execute('alter table ta_person add water text');
    } else if (oldVersion == 3) {}
    oldVersion++;
    //升级后版本还低于当前版本，继续递归升级
    if (oldVersion < newVersion) {
      _onUpgrade(db, oldVersion, newVersion);
    }
    await batch.commit();
  }

  ///
  /// 数据库降级事件
  ///
  static FutureOr<void> _onDowngrade(
      Database db, int oldVersion, int newVersion) async {
    var batch = db.batch();
    await batch.commit();
  }

  ///
  /// 判断数据库表是否存在
  ///
  static Future<bool> isTableExists(String table) async {
    String sql =
        "select * from Sqlite_master where type='table' and name= '$table'";
    var result = await database.rawQuery(sql);
    return result != null && result.length > 0;
  }

  ///
  /// 关闭数据库
  ///
  static Future<void> close() async {
    database.close();
  }
}
