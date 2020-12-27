import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/entity/lrc.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:oktoast/oktoast.dart';

///
/// 歌词组件
///
/// @author zzzz1997
/// @created_time 20201126
///
class LrcWidget extends StatefulWidget {
  @override
  _LrcWidgetState createState() => _LrcWidgetState();
}

///
/// 歌词组件状态
///
class _LrcWidgetState extends State<LrcWidget> {
  // 当前歌曲
  MediaItem _song;

  // 歌词列表
  List<Lrc> _list;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: PlayerBar.screenStateStream,
      builder: (_, snapshot) {
        var song = snapshot.data?.mediaItem;
        if (song != null && _song != song) {
          _song = song;
          // if (mounted) {
          //   setState(() {});
          // }
          _loadLrc();
        }
        return Center(
          child: (_song == null || _list == null || _list.isEmpty)
              ? Text(_song == null
                  ? '歌曲加载中...'
                  : _list == null ? '歌词加载中...' : '暂无歌词')
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  itemBuilder: (_, i) => Center(
                    child: Text(_list[i].lrc),
                  ),
                  separatorBuilder: (_, __) => SizedBox(
                    height: 10,
                  ),
                  itemCount: _list.length,
                ),
        );
      },
    );
  }

  ///
  /// 加载歌词
  ///
  _loadLrc() async {
    var regExp = RegExp(r'\[([0-9]+):([0-9]+).([0-9]+)\](.*)');
    var s = _song.id.split('.');
    var file = File(
        '${_song.id.substring(0, _song.id.length - s[s.length - 1].length)}lrc');
    try {
      _list = [];
      if (await file.exists()) {
        var lines = await file.readAsLines();
        for (var line in lines) {
          var result = regExp.firstMatch(line);
          if (result != null) {
            var lrc = Lrc(
                int.parse(result.group(1)) * 60 * 100 +
                    int.parse(result.group(2)) * 100 +
                    int.parse(result.group(3)),
                result.group(4));
            _list.add(lrc);
          }
        }
        setState(() {});
      }
    } catch (e) {
      Global.logger.e(e);
      showToast(e.toString());
    }
  }
}
