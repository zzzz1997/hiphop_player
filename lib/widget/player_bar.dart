import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/widget/play_button.dart';
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
}

///
/// 播放栏组件状态
///
class _PlayerBarState extends State<PlayerBar> {
  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Style.dividerColor,
          ),
        ),
      ),
      child: StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (_, snapshot) {
          var song = snapshot.data?.mediaItem ??
              MediaItem(
                  id: '', album: '', title: '暂无播放', artist: '未知歌手', artUri: '');
          var isPlaying = snapshot.data?.playbackState?.playing ?? false;
          return Row(
            children: [
              SizedBox(
                width: 10,
              ),
              song.id.isNotEmpty
                  ? ExtendedImage.file(
                      File.fromUri(Uri.parse(song.artUri)),
                      width: 32,
                      height: 32,
                      shape: BoxShape.circle,
                      enableLoadState: true,
                      loadStateChanged: (state) {
                        print(state.extendedImageLoadState);
                        if (state.extendedImageLoadState ==
                            LoadState.completed) {
                          return state.completedWidget;
                        } else {
                          return Icon(
                            IconFonts.album,
                            size: 32,
                          );
                        }
                      },
                    )
                  : Icon(
                      IconFonts.album,
                      size: 32,
                    ),
              SizedBox(
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
              StreamBuilder(
                stream: Stream.periodic(Duration(milliseconds: 200)),
                builder: (_, __) {
                  var position =
                      snapshot.data?.playbackState?.currentPosition ??
                          Duration.zero;
                  return Text(position.toString());
                },
              ),
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    AudioService.pause();
                  } else {
                    AudioService.play();
                  }
                },
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  size: 32,
                ),
              ),
              PlayButton(),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.menu,
                size: 32,
              ),
              SizedBox(
                width: 10,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}
