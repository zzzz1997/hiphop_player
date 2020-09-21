import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';

///
/// 歌单元组件
///
/// @author zzzz1997
/// @created_time 20200911
///
class SongItem extends StatefulWidget {
  // 歌数组
  final List<MediaItem> songs;

  // 位置
  final int index;

  SongItem(this.songs, this.index);

  @override
  _SongItemState createState() => _SongItemState();
}

///
/// 歌单元组件状态
///
class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        var songs = widget.songs.sublist(widget.index) +
            widget.songs.sublist(0, widget.index);
        await AudioService.updateQueue(songs);
        await AudioService.skipToQueueItem(songs[0].id);
        await AudioService.play();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.songs[widget.index].title,
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.songs[widget.index].artist,
                    style: TextStyle(
                      color: Global.brightnessColor(context,
                          light: Style.greyColor),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }
}
