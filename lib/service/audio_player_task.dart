import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// 音频播放器任务
///
/// @author zzzz1997
/// @created_time 20200913
///
class AudioPlayerTask extends BackgroundAudioTask {
  // final _mediaLibrary = MediaLibrary();
  var _player = AudioPlayer();
  AudioProcessingState _skipState;
  Seeker _seeker;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  // List<MediaItem> get queue => _mediaLibrary.items;
  var queue = List<MediaItem>();

  int get index => _player.currentIndex;

  MediaItem get mediaItem => index == null ? null : queue[index];

  // 随机模式
  AudioServiceShuffleMode _shuffleMode;

  // 循环模式
  AudioServiceRepeatMode _repeatMode;

  // 偏好设置
  SharedPreferences _sharedPreferences;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // We configure the audio session for speech since we're playing a podcast.
    // You can also put this in your app's initialisation if your app doesn't
    // switch between two types of audio as this example does.
    // final session = await AudioSession.instance;
    // await session.configure(AudioSessionConfiguration.speech());
    // Broadcast media item changes.
    _sharedPreferences = await SharedPreferences.getInstance();
    queue = _sharedPreferences
        .getStringList(Global.kSongList)
        .map((e) => MediaItem.fromJson(jsonDecode(e)))
        .toList();
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        AudioServiceBackground.setMediaItem(queue[index]);
        _sharedPreferences.setInt(Global.kSongIndex, index);
        _sharedPreferences.setInt(Global.kSongPosition, 0);
      }
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });
    _shuffleMode = AudioServiceShuffleMode
        .values[_sharedPreferences.getInt(Global.kShuffleMode) ?? 0];
    _repeatMode = AudioServiceRepeatMode
        .values[_sharedPreferences.getInt(Global.kRepeatMode) ?? 2];
    await onUpdateQueue(queue);
    await AudioServiceBackground.setMediaItem(
        queue[_sharedPreferences.getInt(Global.kSongIndex)]);
    onSeekTo(Duration(
        milliseconds: _sharedPreferences.getInt(Global.kSongPosition)));
    onSetShuffleMode(_shuffleMode);
    onSetRepeatMode(_repeatMode);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    _skipState = newIndex > index
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    _player.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() {
    _sharedPreferences.setInt(
        Global.kSongPosition, _player.position.inMilliseconds);
    return _player.pause();
  }

  @override
  Future<void> onSeekTo(Duration position) {
    _sharedPreferences.setInt(Global.kSongPosition, position.inMilliseconds);
    return _player.seek(position);
  }

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onUpdateQueue(List<MediaItem> queue) async {
    onPause();
    this.queue = queue;
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.load(ConcatenatingAudioSource(
        children: this
            .queue
            .map((item) => AudioSource.uri(Uri.parse(item.id)))
            .toList(),
      ));
    } catch (e) {
      onStop();
    }
    _sharedPreferences.setStringList(Global.kSongList,
        this.queue.map((e) => jsonEncode(e.toJson())).toList());
    _sharedPreferences.setInt(Global.kSongIndex, 0);
    _sharedPreferences.setInt(Global.kSongPosition, 0);
  }

  @override
  Future<void> onSetShuffleMode(AudioServiceShuffleMode shuffleMode) {
    _shuffleMode = shuffleMode;
    _player.setShuffleModeEnabled(shuffleMode == AudioServiceShuffleMode.all);
    _broadcastState();
    return super.onSetShuffleMode(shuffleMode);
  }

  @override
  Future<void> onSetRepeatMode(AudioServiceRepeatMode repeatMode) {
    _repeatMode = repeatMode;
    _player.setLoopMode(LoopMode.values[repeatMode.index]);
    _broadcastState();
    return super.onSetRepeatMode(repeatMode);
  }

  @override
  Future<void> onStop() async {
    await _player.pause();
    await _player.dispose();
    _eventSubscription.cancel();
    await _broadcastState();
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      shuffleMode: _shuffleMode,
      repeatMode: _repeatMode,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.none:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}
