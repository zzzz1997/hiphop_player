import 'package:flutter/material.dart';

///
/// 基础弹窗
///
/// @author zzzz1997
/// @created_time 20200923
///
class BaseDialog extends StatelessWidget {
  // 子组件
  final Widget child;

  BaseDialog({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: 280,
          height: 400,
          padding: EdgeInsets.all(10),
          child: child,
        ),
      ),
    );
  }
}
