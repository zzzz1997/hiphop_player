import 'dart:math';

import 'package:flutter/material.dart';

///
/// 播放按钮
///
/// @author zzzz1997
/// @created_time 20200915
///
class PlayButton extends StatefulWidget {
  // 百分比
  final double percent;

  // 是否在播放
  final bool isPlaying;

  // 大小
  final double size;

  PlayButton(this.percent, this.isPlaying, {this.size = 32});

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

///
/// 播放按钮状态
///
class _PlayButtonState extends State<PlayButton> {
  @override
  void didUpdateWidget(PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.percent != widget.percent ||
        oldWidget.isPlaying != widget.isPlaying) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _MyPainter(widget.percent, widget.isPlaying, Theme.of(context).accentColor),
    );
  }
}

///
/// 画笔
///
class _MyPainter extends CustomPainter {
  // 百分比
  final double percent;

  // 是否在播放
  final bool isPlaying;

  // 前景色
  final Color foregroundColor;

  _MyPainter(this.percent, this.isPlaying, this.foregroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    var width = min(size.width, size.height);
    var iconPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;
    // var backgroundPaint = Paint()
    //   ..color = Colors.white
    //   ..strokeWidth = 3
    //   ..style = PaintingStyle.stroke;
    var foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (isPlaying) {
      canvas.drawRect(
          Rect.fromLTWH(width / 3, width / 4, width / 9, width / 2), iconPaint);
      canvas.drawRect(
          Rect.fromLTWH(width * 5 / 9, width / 4, width / 9, width / 2),
          iconPaint);
    } else {
      var path = Path();
      var x1 = width / 2 - sqrt(3) * width / 12;
      var x2 = width - sqrt(3) * width / 6;
      path.moveTo(x1, width / 4);
      path.lineTo(x1, width * 3 / 4);
      path.lineTo(x2, width / 2);
      path.close();
      canvas.drawPath(path, iconPaint);
    }
    // canvas.drawCircle(
    //     Offset(size.width / 2, size.height / 2), width / 2, backgroundPaint);
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), -pi / 2,
        2 * pi * percent, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(_MyPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
