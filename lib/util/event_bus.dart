import 'package:audio_service/audio_service.dart';
import 'package:event_bus/event_bus.dart';

///
/// 事件巴士工具类
///
/// @author zzzz1997
/// @created_time 20200913
///
class EventBusUtil {
  // 单例
  static final instance = EventBus();
}

///
/// 音乐查询事件
///
class MusicFindEvent {
  // 歌数组
  List<MediaItem> songs;

  MusicFindEvent(this.songs);
}