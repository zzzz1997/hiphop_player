import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/common/route.dart';
import 'package:hiphop_player/widget/albun_art.dart';
import 'package:hiphop_player/widget/play_button.dart';
import 'package:hiphop_player/widget/play_list.dart';
import 'package:rxdart/rxdart.dart';

///
/// 播放栏组件
///
/// @author zzzz1997
/// @created_time 20200913
///
class PlayerBar extends StatefulWidget {
  @override
  _PlayerBarState createState() => _PlayerBarState();

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  static Stream<ScreenState> get screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState))
        ..asBroadcastStream();
}

///
/// 播放栏组件状态
///
class _PlayerBarState extends State<PlayerBar> {
  // 专辑封面
  var _albumArt = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        MyRoute.pushNamed(MyRoute.detail,
            animationType: AnimationType.IN_FROM_BOTTOM,
            arguments: {'albumArt': _albumArt});
      },
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Style.dividerColor,
            ),
          ),
        ),
        child: StreamBuilder<ScreenState>(
          stream: PlayerBar.screenStateStream,
          builder: (_, snapshot) {
            var song = snapshot.data?.mediaItem ??
                MediaItem(
                    id: '',
                    album: '',
                    title: Global.s.noPlayback,
                    artist: Global.s.unknownSinger,
                    artUri: _albumArt);
            var isPlaying = snapshot.data?.playbackState?.playing ?? false;
            _albumArt = song.artUri;
            return Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Hero(
                  tag: song.artUri,
                  child: AnimateAlbumArt(song.artUri, isPlaying),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Global.brightnessColor(context,
                              light: Style.greyColor),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isPlaying) {
                      AudioService.pause();
                    } else {
                      AudioService.play();
                    }
                  },
                  child: StreamBuilder(
                    stream: Stream.periodic(Duration(milliseconds: 200)),
                    builder: (_, __) {
                      var position = snapshot.data?.playbackState
                              ?.currentPosition?.inMilliseconds ??
                          0;
                      var duration =
                          snapshot.data?.mediaItem?.duration?.inMilliseconds ??
                              1;
                      return PlayButton(position / duration, isPlaying);
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.queue_music,
                    size: 32,
                  ),
                  onPressed: () {
                    showPlayListSheet(context);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

///
/// 音乐状态
///
class ScreenState {
  // 歌单
  final List<MediaItem> queue;

  // 当前播放
  final MediaItem mediaItem;

  // 播放状态
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}
