// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SongList _$SongListFromJson(Map<String, dynamic> json) {
  return SongList(
    json['id'] as int,
    json['name'] as String,
    json['cover'] as String,
    json['number'] as int,
    (jsonDecode((json['songs'] as String) ?? '[]') as List)
        ?.map((e) =>
            e == null ? null : MediaItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SongListToJson(SongList instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover': instance.cover,
      'number': instance.number,
      'songs': jsonEncode(instance.songs.map((e) => e.toJson()).toList()),
    };
