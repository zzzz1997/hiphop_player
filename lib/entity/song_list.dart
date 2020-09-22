import 'dart:convert';

import 'package:audio_service/audio_service.dart';

part 'song_list.g.dart';

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

  factory SongList.fromJson(Map<String, dynamic> json) =>
      _$SongListFromJson(json);

  Map<String, dynamic> toJson() => _$SongListToJson(this);
}
