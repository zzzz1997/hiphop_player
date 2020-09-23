import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/entity/song_list.dart';
import 'package:hiphop_player/sqflite/provider/song_list.dart';
import 'package:hiphop_player/util/event_bus.dart';
import 'package:hiphop_player/widget/albun_art.dart';
import 'package:hiphop_player/widget/base_dialog.dart';
import 'package:hiphop_player/widget/new_song_list.dart';
import 'package:oktoast/oktoast.dart';

///
/// 歌单页面
///
/// @author zzzz1997
/// @created_time 20200923
///
class _SongListFragment extends StatefulWidget {
  // 歌曲列表
  final List<MediaItem> songs;

  _SongListFragment(this.songs);

  @override
  _SongListFragmentState createState() => _SongListFragmentState();
}

///
/// 歌单页面状态
///
class _SongListFragmentState extends State<_SongListFragment> {
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(Global.s.collectToSongList),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) =>
                  _buildSongList(i == 0 ? null : Global.songLists[i - 1]),
              separatorBuilder: (_, __) => SizedBox(
                height: 10,
              ),
              itemCount: Global.songLists.length + 1,
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// 构建歌单
  ///
  Widget _buildSongList(SongList songList) {
    Widget title = Text(songList?.name ?? '新键歌单');
    if (songList != null) {
      title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          Text(
            '${songList.number}${Global.s.songs}',
            style: TextStyle(
              color: Global.brightnessColor(context, light: Style.greyColor),
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (songList == null) {
          var b = await showNewSongListDialog(context, widget.songs);
          if (b != null && b) {
            Global.navigator.pop(true);
          }
        } else {
          try {
            var list = await SongListProvider.query(songList.id);
            var songs =
                widget.songs.where((element) => !list.songs.contains(element));
            if (songs.isEmpty) {
              showToast(Global.s.songAlreadyExists);
              return;
            }
            list.songs.insertAll(0, songs);
            list.number = list.songs.length;
            list.cover = list.songs[0].artUri;
            await SongListProvider.update(list);
            showToast(Global.s.collectedToSongList);
            Global.navigator.pop(true);
          } catch (e) {
            showToast(e.toString());
          }
        }
      },
      child: Row(
        children: [
          songList == null
              ? const Icon(
                  Icons.add,
                  size: 40,
                )
              : AlbumArt(
                  songList.cover,
                  size: 40,
                  shape: BoxShape.rectangle,
                ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: title,
          ),
        ],
      ),
    );
  }
}

///
/// 展示歌单
///
Future<bool> showSongListDialog(BuildContext context, List<MediaItem> songs) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _SongListFragment(songs),
  );
}
