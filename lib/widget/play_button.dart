import 'package:flutter/material.dart';

///
/// 播放按钮
///
/// @author zzzz1997
/// @created_time 20200915
///
class PlayButton extends StatefulWidget {
  @override
  _PlayButtonState createState() => _PlayButtonState();
}

///
/// 播放按钮状态
///
class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(32, 32),
      painter: MyPainter(50),
    );
  }
}

class MyPainter extends CustomPainter {
  // 百分比
  final double percent;

  MyPainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke;
    var p = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    var path = Path();
    path.moveTo(10, 10);
    path.lineTo(10, 22);
    path.lineTo(20, 16);
    path.close();
    canvas.drawPath(path, p);
    canvas.drawCircle(
        Offset(size.width / 2, size.width / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
