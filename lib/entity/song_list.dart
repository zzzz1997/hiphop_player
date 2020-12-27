import 'dart:convert';

import 'package:audio_service/audio_service.dart';

///
/// 歌单实体
///
/// @author zzzz1997
/// @created_time 20200922
///
class SongList {
  // id
  int id;

  // 歌单名
  String name;

  // 封面
  String cover;

  // 数量
  int number;

  // 歌曲列表
  List<MediaItem> songs;

  SongList(this.id, this.name, this.cover, this.number, this.songs);

  factory SongList.fromJson(Map<String, dynamic> json) => SongList(
        json['id'] as int,
        json['name'] as String,
        json['cover'] as String,
        json['number'] as int,
        (jsonDecode((json['songs'] as String) ?? '[]') as List)
            ?.map((e) => e == null
                ? null
                : MediaItem.fromJson(e as Map<String, dynamic>))
            ?.toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'cover': cover,
        'number': number,
        'songs': jsonEncode(songs.map((e) => e.toJson()).toList()),
      };
}
