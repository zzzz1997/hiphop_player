import 'dart:async';

import 'package:flutter/services.dart';

class MusicFinder {
  static const _channel = const MethodChannel('music');

  static Future<dynamic> findSongs() async {
    var completer = new Completer();

    Map params = <String, dynamic>{
      "handlePermissions": true,
      "executeAfterPermissionGranted": true,
    };
    List<dynamic> songs = await _channel.invokeMethod('find', params);
    print(songs);
//    var mySongs = songs.map((m) => new Song.fromMap(m)).toList();
//    completer.complete(mySongs);
    return completer.future;
  }
}
