import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:hiphop_player/util/music_finder.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:hiphop_player/widget/song_item.dart';

///
/// 列表页面
///
/// @author zzzz1997
/// @created_time 20200914
///
class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

///
/// 列表页面状态
///
class _ListPageState extends State<ListPage> {
  // 音乐列表
  var _songs = List<MediaItem>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      EasyLoading.show();
      _songs = await MusicItemProvider.queryAll();
      if (_songs.isNotEmpty) {
        setState(() {});
      }
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text(Global.s.songList),
        ),
        body: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_songs.isNotEmpty) {
                  AudioService.updateQueue(_songs);
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.play_circle_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text('全部播放'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _songs.isEmpty
                  ? Center(
                      child: FlatButton(
                        child: const Text('暂无歌曲，搜索本地'),
                        onPressed: () async {
                          EasyLoading.show();
                          _songs = await MusicUtil.findSongs();
                          if (_songs.isNotEmpty) {
                            setState(() {});
                            MusicItemProvider.insertList(_songs);
                          }
                          EasyLoading.dismiss();
                        },
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (_, i) => SongItem(_songs, i),
                      itemCount: _songs.length,
                    ),
            ),
            PlayerBar(),
          ],
        ),
      ),
    );
  }
}
