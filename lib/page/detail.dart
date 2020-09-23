import 'dart:math';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/widget/albun_art.dart';
import 'package:hiphop_player/widget/play_list.dart';
import 'package:hiphop_player/widget/player_bar.dart';

///
/// 详情页面
///
/// @author zzzz1997
/// @created_time 20200916
///
class DetailPage extends StatefulWidget {
  // 专辑封面
  final String albumArt;

  DetailPage(this.albumArt);

  @override
  _DetailPageState createState() => _DetailPageState();
}

///
/// 详情页面状态
///
class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState>(
      stream: PlayerBar.screenStateStream,
      builder: (_, snapshot) {
        var song = snapshot.data?.mediaItem ??
            MediaItem(
                id: '',
                album: '',
                title: Global.s.noPlayback,
                artist: Global.s.unknownSinger,
                artUri: widget.albumArt);
        var isPlaying = snapshot.data?.playbackState?.playing ?? false;
        var shuffleMode = snapshot.data?.playbackState?.shuffleMode;
        var repeatMode = snapshot.data?.playbackState?.repeatMode;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey.withOpacity(0.6),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                Text(
                  song.artist,
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              AlbumArt(
                song.artUri,
                size: Global.mediaQuery.size.height,
                shape: BoxShape.rectangle,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ),
                child: Container(
                  width: Global.mediaQuery.size.width,
                  height: Global.mediaQuery.size.height,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Hero(
                        tag: widget.albumArt,
                        child: AnimateAlbumArt(
                          song.artUri,
                          isPlaying,
                          size: 200,
                        ),
                      ),
                    ),
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: StreamBuilder(
                        stream:
                            Stream.periodic(const Duration(milliseconds: 200)),
                        builder: (_, __) {
                          var position = snapshot.data?.playbackState
                                  ?.currentPosition?.inMilliseconds ??
                              0;
                          var duration = snapshot
                                  .data?.mediaItem?.duration?.inMilliseconds ??
                              1;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_format(position)),
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white,
                                  value: min(position / duration, 1),
                                  onChanged: (value) {
                                    AudioService.seekTo(Duration(
                                        milliseconds:
                                            (duration * value).toInt()));
                                  },
                                ),
                              ),
                              Text(_format(duration)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  IconTheme(
                    data: const IconThemeData(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            repeatMode == AudioServiceRepeatMode.all
                                ? Icons.repeat
                                : shuffleMode == AudioServiceShuffleMode.all
                                    ? Icons.shuffle
                                    : Icons.repeat_one,
                            size: 32,
                          ),
                          onPressed: () {
                            if (repeatMode == AudioServiceRepeatMode.all) {
                              AudioService.setShuffleMode(
                                  AudioServiceShuffleMode.all);
                              AudioService.setRepeatMode(
                                  AudioServiceRepeatMode.none);
                              Global.sharedPreferences.setInt(
                                  Global.kShuffleMode,
                                  AudioServiceShuffleMode.all.index);
                              Global.sharedPreferences.setInt(
                                  Global.kRepeatMode,
                                  AudioServiceRepeatMode.none.index);
                            } else if (shuffleMode ==
                                AudioServiceShuffleMode.all) {
                              AudioService.setShuffleMode(
                                  AudioServiceShuffleMode.none);
                              AudioService.setRepeatMode(
                                  AudioServiceRepeatMode.one);
                              Global.sharedPreferences.setInt(
                                  Global.kShuffleMode,
                                  AudioServiceShuffleMode.none.index);
                              Global.sharedPreferences.setInt(
                                  Global.kRepeatMode,
                                  AudioServiceRepeatMode.one.index);
                            } else {
                              AudioService.setRepeatMode(
                                  AudioServiceRepeatMode.all);
                              Global.sharedPreferences.setInt(
                                  Global.kRepeatMode,
                                  AudioServiceRepeatMode.all.index);
                            }
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 32,
                          ),
                          onPressed: () {
                            AudioService.skipToPrevious();
                            AudioService.setShuffleMode(
                                AudioServiceShuffleMode.all);
                          },
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 70,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                AudioService.pause();
                              } else {
                                AudioService.play();
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            size: 32,
                          ),
                          onPressed: () {
                            AudioService.skipToNext();
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.queue_music,
                            size: 32,
                          ),
                          onPressed: () {
                            showPlayListSheet(context);
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  ///
  /// 时间格式化
  ///
  String _format(int milliseconds) {
    var seconds = milliseconds ~/ 1000;
    var minute = seconds ~/ 60;
    var second = seconds % 60;
    return '${minute < 10 ? '0' : ''}$minute:${second < 10 ? '0' : ''}$second';
  }
}
