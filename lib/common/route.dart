import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/page/detail.dart';
import 'package:hiphop_player/page/home.dart';
import 'package:hiphop_player/page/list.dart';
import 'package:hiphop_player/page/setting.dart';
import 'package:hiphop_player/page/splash.dart';

///
/// 动画类型
///
enum AnimationType {
  // 无动画
  NO_ANIM,
  // 浅入浅出
  FADE_IN,
  // Android质感
  MATERIAL,
  // IOS风格
  CUPERTINO,
  // 从左进入
  IN_FROM_LEFT,
  // 从右进入
  IN_FROM_RIGHT,
  // 从底进入
  IN_FROM_BOTTOM
}

///
/// 自定义路由
///
/// @author zzzz1997
/// @created_time 20191121
///
class MyRoute {
  // 开屏路由
  static const splash = 'splash';

  // 主页路由
  static const home = '/';

  // 列表路由
  static const list = 'list';

  // 详情路由
  static const detail = 'detail';

  // 设置路由
  static const setting = 'setting';

  ///
  /// 构造路由
  ///
  static Route generateRoute(RouteSettings settings) {
    Map arguments = settings.arguments;
    AnimationType animationType = arguments != null
        ? arguments['animationType'] ?? AnimationType.NO_ANIM
        : AnimationType.NO_ANIM;
    Map map = arguments != null ? arguments['arguments'] ?? {} : {};
    switch (animationType) {
      case AnimationType.NO_ANIM:
        return PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => _buildPage(settings.name, map),
          transitionDuration: Duration(milliseconds: 0),
          transitionsBuilder: (_, __, ___, child) => child,
        );
      case AnimationType.FADE_IN:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => _buildPage(settings.name, map),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: Tween(begin: 0.1, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
      case AnimationType.MATERIAL:
        return MaterialPageRoute(
          builder: (context) => _buildPage(settings.name, map),
        );
      case AnimationType.CUPERTINO:
        return CupertinoPageRoute(
          builder: (context) => _buildPage(settings.name, map),
        );
      case AnimationType.IN_FROM_LEFT:
      case AnimationType.IN_FROM_RIGHT:
      case AnimationType.IN_FROM_BOTTOM:
        const Offset topLeft = Offset(0.0, 0.0);
        const Offset topRight = Offset(1.0, 0.0);
        const Offset bottomLeft = Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (animationType == AnimationType.IN_FROM_LEFT) {
          startOffset = Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (animationType == AnimationType.IN_FROM_RIGHT) {
          startOffset = topRight;
          endOffset = topLeft;
        }
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => _buildPage(settings.name, map),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(begin: startOffset, end: endOffset)
                .animate(animation),
            child: child,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for $animationType'),
            ),
          ),
        );
    }
  }

  ///
  /// 根据名称跳转
  ///
  static Future<T> pushNamed<T>(String routeName,
      {AnimationType animationType, Object arguments}) {
    return Global.navigator.pushNamed<T>(routeName,
        arguments: _combineArguments(animationType, arguments));
  }

  ///
  /// 根据名称跳转并移除筛选的路由
  ///
  static Future<T> pushNamedAndRemoveUntil<T>(
      String routeName, RoutePredicate predicate,
      {AnimationType animationType, Object arguments}) {
    return Global.navigator.pushNamedAndRemoveUntil<T>(routeName, predicate,
        arguments: _combineArguments(animationType, arguments));
  }

  ///
  /// 根据名称跳转替换当前页面
  ///
  static Future<T> pushReplacementNamed<T, TO>(String routeName,
      {AnimationType animationType, TO result, Object arguments}) {
    return Global.navigator.pushReplacementNamed<T, TO>(routeName,
        result: result, arguments: _combineArguments(animationType, arguments));
  }

  ///
  /// 根据名称跳转并退出当前页面
  ///
  static Future<T> popAndPushNamed<T, TO>(String routeName,
      {AnimationType animationType, TO result, Object arguments}) {
    return Global.navigator.popAndPushNamed<T, TO>(routeName,
        result: result, arguments: _combineArguments(animationType, arguments));
  }

  ///
  /// 构建页面
  ///
  static Widget _buildPage(String name, Map map) {
    switch (name) {
      case splash:
        return SplashPage();
      case home:
        return AudioServiceWidget(child: HomePage());
      case list:
        return ListPage(map['id']);
      case detail:
        return DetailPage(map['albumArt']);
      case setting:
        return SettingPage();
      default:
        return Scaffold(
          body: Center(
            child: Text('No route defined for $name'),
          ),
        );
    }
  }

  ///
  /// 组合参数
  ///
  static Object _combineArguments(
      AnimationType animationType, Object arguments) {
    return {
      'animationType': animationType ?? AnimationType.MATERIAL,
      'arguments': arguments,
    };
  }
}
