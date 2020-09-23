import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/entity/song_list.dart';
import 'package:hiphop_player/sqflite/provider/song_list.dart';
import 'package:hiphop_player/util/event_bus.dart';
import 'package:oktoast/oktoast.dart';

///
/// 新键歌单页面
///
/// @author zzzz1997
/// @created_time 20200923
///
class _NewSongListListFragment extends StatefulWidget {
  // 歌曲列表
  final List<MediaItem> songs;

  _NewSongListListFragment(this.songs);

  @override
  _NewSongListListFragmentState createState() =>
      _NewSongListListFragmentState();
}

///
/// 新键歌单页面状态
///
class _NewSongListListFragmentState extends State<_NewSongListListFragment> {
  // 输入控制器
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Global.s.newSongList),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: Global.s.inputSongListTitle,
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Global.navigator.pop();
          },
          child: Text(Global.s.cancel),
        ),
        FlatButton(
          onPressed: () async {
            var text = _controller.text;
            if (text.isEmpty) {
              showToast(Global.s.inputSongListTitle);
              return;
            }
            try {
              var songList = SongList(0, text, widget.songs[0].artUri,
                  widget.songs.length, widget.songs);
              var id = await SongListProvider.insert(songList);
              songList.id = id;
              Global.songLists.add(songList);
              EventBusUtil.instance.fire(SongListUpdateEvent());
              showToast(Global.s.songListAddedSuccess);
              Global.navigator.pop(true);
            } catch (e) {
              showToast(e.toString());
            }
          },
          child: Text(Global.s.conform),
        ),
      ],
    );
  }
}

///
/// 展示歌单
///
Future<bool> showNewSongListDialog(
    BuildContext context, List<MediaItem> songs) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _NewSongListListFragment(songs),
  );
}
