import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiphop_player/common/resource.dart';

///
/// 专辑封面组件
///
/// @author zzzz1997
/// @created_time 20200915
///
class AlbumArt extends StatefulWidget {
  // 专辑封面
  final String albumArt;

  // 图片大小
  final double size;

  AlbumArt(this.albumArt, {this.size = 32});

  @override
  _AlbumArtState createState() => _AlbumArtState();
}

///
/// 专辑封面组件状态
///
class _AlbumArtState extends State<AlbumArt>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  AnimationController _controller;

  // 动画
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 60), vsync: this);
    _animation = Tween(begin: 0.0, end: 2 * pi).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      alignment: Alignment.center,
      child: widget.albumArt.isNotEmpty
          ? ImageHelper.fileImage(
              File.fromUri(Uri.parse(widget.albumArt)),
              width: 32,
              height: 32,
              shape: BoxShape.circle,
            )
          : Icon(
              IconFonts.album,
              size: 32,
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
