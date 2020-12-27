import 'package:json_annotation/json_annotation.dart';

part 'lrc.g.dart';

///
/// 歌词实体
///
/// @author zzzz1997
/// @created_time 20201126
///
@JsonSerializable()
class Lrc {
  // id
  int time;

  // 封面
  String lrc;

  Lrc(this.time, this.lrc);

  factory Lrc.fromJson(Map<String, dynamic> json) =>
      _$LrcFromJson(json);

  Map<String, dynamic> toJson() => _$LrcToJson(this);
}
