import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/util/music_finder.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:hiphop_player/widget/song_item.dart';
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
  // 音乐列表
  var _songs = List<MediaItem>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.s.appName),
      ),
      body: ListTileTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text('找歌${_songs.length}'),
              onPressed: () async {
                EasyLoading.show();
                _songs = await MusicUtil.findSongs();
                setState(() {});
                EasyLoading.dismiss();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, i) => SongItem(_songs, i),
                itemCount: _songs.length,
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
              accountName: Text(r'BO$$X'),
              accountEmail: Text('CDC 说唱会馆'),
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
            Spacer(),
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
                    onTap: () {
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
