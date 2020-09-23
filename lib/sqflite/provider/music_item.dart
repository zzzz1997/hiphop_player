import 'package:audio_service/audio_service.dart';
import 'package:hiphop_player/sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';

///
/// 歌提供者
///
/// @author zzzz1997
/// @created_time 20200914
///
class MusicItemProvider {
  // 表名
  static final _table = 'local_song';

  ///
  /// 创建表
  ///
  static Future createTable(Database db) async {
    // if (!(await SqfliteUtil.isTableExists(_table))) {
    await db.execute(
        'CREATE TABLE $_table (id TEXT NOT NULL PRIMARY KEY, albumId INTEGER NOT NULL, album TEXT NOT NULL, title TEXT NOT NULL, artist TEXT NOT NULL, genre TEXT, duration INTEGER NOT NULL, artUri TEXT, displayTitle TEXT NOT NULL, displaySubtitle TEXT NOT NULL, displayDescription TEXT NOT NULL)');
    // }
  }

  ///
  /// 插入单条数据
  ///
  static Future<int> insert(MediaItem mediaItem) async {
    var json = mediaItem.toJson();
    json['albumId'] = mediaItem.extras['albumId'];
    json.remove('playable');
    json.remove('rating');
    json.remove('extras');
    return await SqfliteUtil.database.insert(_table, json);
  }

  ///
  /// 插入多条数据
  ///
  static Future<List<dynamic>> insertList(List<MediaItem> mediaItems) async {
    var batch = SqfliteUtil.database.batch();
    mediaItems.forEach((element) {
      var json = element.toJson();
      json['albumId'] = element.extras['albumId'];
      json.remove('playable');
      json.remove('rating');
      json.remove('extras');
      batch.insert(_table, json);
    });
    return await batch.commit();
  }

  ///
  /// 查询数量
  ///
  static Future<int> count() async {
    return Sqflite.firstIntValue(
        await SqfliteUtil.database.rawQuery('SELECT COUNT(*) FROM $_table'));
  }

  ///
  /// 检索单条数据
  ///
  static Future<MediaItem> query(String id) async {
    var maps = await SqfliteUtil.database
        .query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.length == 1) {
      var json = maps.first;
      json['extras'] = {'albumId': json['albumId']};
      return MediaItem.fromJson(json);
    }
    return null;
  }

  ///
  /// 检索所有数据
  ///
  static Future<List<MediaItem>> queryAll() async {
    var maps = await SqfliteUtil.database.query(_table);
    return maps.map((e) {
      var json = {...e};
      json['extras'] = {'albumId': json['albumId']};
      return MediaItem.fromJson(json);
    }).toList();
  }

  ///
  /// 删除单条数据
  ///
  static Future<int> delete(List<String> ids) async {
    return await SqfliteUtil.database
        .delete(_table, where: 'id = ?', whereArgs: ids);
  }

  ///
  /// 删除所有数据
  ///
  static Future<int> clear() async {
    return await SqfliteUtil.database.delete(_table);
  }
}
