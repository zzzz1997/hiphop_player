import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/widget/player_bar.dart';

///
/// 播放列表页面
///
/// @author zzzz1997
/// @created_time 20200922
///
class _PlayListFragment extends StatefulWidget {
  @override
  __PlayListFragmentState createState() => __PlayListFragmentState();
}

///
/// 播放列表页面状态
///
class __PlayListFragmentState extends State<_PlayListFragment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: StreamBuilder<ScreenState>(
        stream: PlayerBar.screenStateStream,
        builder: (_, snapshot) {
          var song = snapshot.data?.mediaItem ??
              MediaItem(
                  id: '', album: '', title: '暂无播放', artist: '未知歌手', artUri: '');
          var songs = snapshot.data?.queue ?? [];
          return Column(
            children: [
              Row(
                children: [
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Global.s.currentPlay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' (${songs.length})',
                          style: TextStyle(
                            color: Global.brightnessColor(context,
                                light: Style.greyColor),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, i) {
                    var s = songs[i];
                    var play = s == song;
                    var color = Theme.of(context).accentColor;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        await AudioService.skipToQueueItem(s.id);
                        await AudioService.play();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            alignment: Alignment.center,
                            child: play
                                ? Icon(
                                    Icons.equalizer,
                                    color: color,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      height: 1,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: s.title,
                                    style: TextStyle(
                                      color: Global.brightnessColor(context,
                                          light: play ? color : Colors.black),
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' - ${s.artist}',
                                    style: TextStyle(
                                      color: Global.brightnessColor(context,
                                          light:
                                              play ? color : Style.greyColor),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                height: 1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Global.brightnessColor(context,
                                    light: Style.greyColor),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(
                    height: 15,
                  ),
                  itemCount: songs.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

///
/// 展示播放列表
///
showPlayList(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15),
      ),
    ),
    // isScrollControlled: true,
    builder: (_) => _PlayListFragment(),
  );
}
