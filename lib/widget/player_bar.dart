import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/resource.dart';
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
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Style.greyColor,
          ),
        ),
      ),
      child: StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (_, snapshot) {
          var song = snapshot.data?.mediaItem;
          return Row(
            children: [
              if (song != null)
              Image.file(File.fromUri(Uri.parse(song.artUri))),
              StreamBuilder(
                stream: Stream.periodic(Duration(milliseconds: 200)),
                builder: (_, __) {
                  var position = snapshot.data?.playbackState?.currentPosition ??
                      Duration.zero;
                  return Text(position.toString());
                },
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
