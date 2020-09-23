import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/entity/song_list.dart';
import 'package:hiphop_player/sqflite/sqflite.dart';
import 'package:hiphop_player/util/event_bus.dart';
import 'package:sqflite/sqflite.dart';

///
/// 歌单提供者
///
/// @author zzzz1997
/// @created_time 20200922
///
class SongListProvider {
  // 表名
  static final _table = 'song_list';

  ///
  /// 创建表
  ///
  static Future createTable(Database db) async {
    // if (!(await SqfliteUtil.isTableExists(_table))) {
    await db.execute(
        'CREATE TABLE $_table (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, cover TEXT NOT NULL, number INTEGER NOT NULL, songs TEXT NOT NULL)');
    // }
  }

  ///
  /// 插入单条数据
  ///
  static Future<int> insert(SongList songList) async {
    return await SqfliteUtil.database.insert(_table, songList.toJson());
  }

  ///
  /// 插入多条数据
  ///
  static Future<List<dynamic>> insertList(List<SongList> songLists) async {
    var batch = SqfliteUtil.database.batch();
    songLists.forEach((element) {
      batch.insert(_table, element.toJson());
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
  static Future<SongList> query(int id) async {
    var maps = await SqfliteUtil.database
        .query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.length == 1) {
      return SongList.fromJson(maps.first);
    }
    return null;
  }

  ///
  /// 检索所有数据
  ///
  static Future<List<SongList>> queryAll() async {
    var maps = await SqfliteUtil.database.query(_table);
    return maps.map((e) {
      return SongList.fromJson(e);
    }).toList();
  }

  ///
  /// 检索除了歌曲字段的所有数据
  ///
  static Future<List<SongList>> queryAllWithoutSongs() async {
    var maps = await SqfliteUtil.database
        .query(_table, columns: ['id', 'name', 'cover', 'number']);
    return maps.map((e) {
      return SongList.fromJson(e);
    }).toList();
  }

  ///
  /// 更新歌单
  ///
  static Future<int> update(SongList songList) async {
    var length = await SqfliteUtil.database.update(_table, songList.toJson(),
        where: 'id = ?', whereArgs: [songList.id]);
    Global.songLists[Global.songLists
        .indexWhere((element) => element.id == songList.id)] = songList;
    EventBusUtil.instance.fire(SongListUpdateEvent());
    return length;
  }

  ///
  /// 删除单条数据
  ///
  static Future<int> delete(int id) async {
    return await SqfliteUtil.database
        .delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  ///
  /// 删除所有数据
  ///
  static Future<int> clear() async {
    return await SqfliteUtil.database.delete(_table);
  }
}
