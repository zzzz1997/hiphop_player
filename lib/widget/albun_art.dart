import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/resource.dart';

///
/// 动态专辑封面组件
///
/// @author zzzz1997
/// @created_time 20200915
///
class AnimateAlbumArt extends StatefulWidget {
  // 专辑封面
  final String albumArt;

  // 是否在播放
  final bool isPlaying;

  // 图片大小
  final double size;

  AnimateAlbumArt(this.albumArt, this.isPlaying, {this.size = 32});

  @override
  _AnimateAlbumArtState createState() => _AnimateAlbumArtState();
}

///
/// 专辑封面组件状态
///
class _AnimateAlbumArtState extends State<AnimateAlbumArt>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 20), vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimateAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.albumArt != widget.albumArt) {
      setState(() {});
    }
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      alignment: Alignment.center,
      child: AlbumArt(widget.albumArt, size: widget.size),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

///
/// 专辑封面
///
class AlbumArt extends StatelessWidget {
  // 专辑封面
  final String albumArt;

  // 图片大小
  final double size;

  // 形状
  final BoxShape shape;

  AlbumArt(this.albumArt, {this.size = 32, this.shape = BoxShape.circle});

  @override
  Widget build(BuildContext context) {
    return albumArt.isNotEmpty
        ? ExtendedImage.file(
            File.fromUri(Uri.parse(albumArt)),
            width: size,
            height: size,
            shape: shape,
            enableLoadState: true,
            fit: BoxFit.cover,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.completed) {
                return state.completedWidget;
              } else {
                return Icon(
                  IconFonts.album,
                  size: size,
                );
              }
            },
          )
        : Icon(
            IconFonts.album,
            size: size,
          );
  }
}
