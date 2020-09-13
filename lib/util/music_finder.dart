import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

///
/// 音乐工具类
///
/// @author zzzz1997
/// @created_time 20200912
///
class MusicUtil {
  // 方法通道
  static const _channel = const MethodChannel('music');

  ///
  /// 查找所有音乐
  ///
  static Future<List<MediaItem>> findSongs() async {
    // var completer = Completer<List<MediaItem>>();
    List<dynamic> songs = await _channel.invokeMethod('find');
    print(jsonEncode(songs));
    return songs
        .map((m) => MediaItem.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    // completer.complete(mySongs);
    // return completer.future;
  }
}
