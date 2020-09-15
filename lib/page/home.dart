import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:hiphop_player/sqflite/sqflite.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:provider/provider.dart';

import '../common/global.dart';
import '../common/resource.dart';
import '../common/route.dart';
import '../model/theme.dart';

///
/// 主页面
///
/// @author zzzz1997
/// @created_time 20200911
///
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

///
/// 主页面状态
///
class _HomePageState extends State<HomePage> {
  // 数量
  var _count = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      EasyLoading.show();
      _count = await MusicItemProvider.count();
      if (_count > 0) {
        setState(() {});
      }
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.s.appName),
      ),
      body: ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            MyRoute.pushNamed(MyRoute.list);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Theme.of(context).accentColor,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: '音乐',
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: '($_count)',
                                      style: TextStyle(
                                        color: Global.brightnessColor(
                                          context,
                                          light: Style.greyColor,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            PlayerBar(),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text(r'BO$$X'),
              accountEmail: const Text('CDC 说唱会馆'),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    ImageHelper.assetImageProvider('im_avatar.jpg'),
              ),
            ),
            ListTile(
              onTap: () {
                MyRoute.pushNamed(MyRoute.setting);
              },
              leading: Icon(
                Icons.settings,
                color: Theme.of(context).accentColor,
              ),
              title: Text(Global.s.setting),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(Global.s.darkMode),
                    onTap: () {
                      _switchDarkMode(context);
                    },
                    leading: Transform.rotate(
                      angle: -pi,
                      child: Icon(
                        Theme.of(context).brightness == Brightness.light
                            ? Icons.brightness_5
                            : Icons.brightness_2,
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(Global.s.exit),
                    onTap: () async {
                      await SqfliteUtil.close();
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// 切换夜间模式
  ///
  _switchDarkMode(context) {
    if (Global.mediaQuery.platformBrightness == Brightness.dark) {
      Global.toast('检测到系统为暗黑模式,已为你自动切换');
    } else {
      Provider.of<ThemeModel>(context, listen: false).switchTheme(
        isDarkMode: Theme.of(context).brightness == Brightness.light,
      );
    }
  }
}
