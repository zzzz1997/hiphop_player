import 'dart:async';

import 'package:flutter/material.dart';

import 'package:hiphop_player/common/global.dart';

///
/// 播放栏模型
///
/// @author zzzz1997
/// @created_time 20200913
///
class PlayerBarModel extends ChangeNotifier {
  PlayerBarModel() {
    _streamDemo = StreamController.broadcast();
    _sinkDemo = _streamDemo.sink;
  }

  StreamSubscription _streamDemoSubscription;
  StreamController<String> _streamDemo;
  StreamSink _sinkDemo;
}
