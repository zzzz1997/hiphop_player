import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/common/route.dart';
import 'package:hiphop_player/entity/song_list.dart';
import 'package:hiphop_player/model/theme.dart';
import 'package:hiphop_player/service/audio_player_task.dart';
import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:hiphop_player/sqflite/provider/song_list.dart';
import 'package:hiphop_player/sqflite/sqflite.dart';
import 'package:hiphop_player/util/event_bus.dart';
import 'package:hiphop_player/widget/albun_art.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

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

    AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'hiphop_player',
      // Enable this if you want the Android service to exit the foreground state on pause.
      //androidStopForegroundOnPause: true,
      // androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
    );
    EventBusUtil.instance.on<SongListUpdateEvent>().listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.s.appName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
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
                            MyRoute.pushNamed(MyRoute.list).then((_) {
                              _init();
                            });
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.music_note,
                                size: 32,
                                color: Theme.of(context).accentColor,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: Global.s.music,
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
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                      ),
                      child: Text(
                        '我的歌单',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    itemBuilder: (_, i) => _buildSongList(Global.songLists[i]),
                    separatorBuilder: (_, __) => SizedBox(
                      height: 10,
                    ),
                    itemCount: Global.songLists.length,
                  ),
                ],
              ),
            ),
          ),
          PlayerBar(),
        ],
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
  /// 构建歌单
  ///
  Widget _buildSongList(SongList songList) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        MyRoute.pushNamed(MyRoute.list, arguments: {
          'id': songList.id,
        });
      },
      child: Row(
        children: [
          songList == null
              ? const Icon(
                  Icons.add,
                  size: 40,
                )
              : AlbumArt(
                  songList.cover,
                  size: 40,
                  shape: BoxShape.rectangle,
                ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(songList.name),
                Text(
                  '${songList.number}${Global.s.songs}',
                  style: TextStyle(
                    color:
                        Global.brightnessColor(context, light: Style.greyColor),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => <PopupMenuItem<String>>[
                PopupMenuItem(
                  value: '编辑信息',
                  child: Text(Global.s.editInfo),
                ),
                PopupMenuItem(
                  value: '删除',
                  child: Text(Global.s.delete),
                ),
              ],
              onSelected: (s) {
                switch (s) {
                  case '编辑信息':
                    break;
                  case '删除':
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: Text(Global.s.conformDeleteSongList),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Global.navigator.pop();
                            },
                            child: Text(Global.s.cancel),
                          ),
                          FlatButton(
                            onPressed: () async {
                              try {
                                await SongListProvider.delete(songList.id);
                                Global.songLists.remove(songList);
                                setState(() {});
                              } catch (e) {
                                showToast(e.toString());
                              }
                              Global.navigator.pop();
                            },
                            child: Text(Global.s.delete),
                          ),
                        ],
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// 初始化
  ///
  _init() async {
    EasyLoading.show();
    _count = await MusicItemProvider.count();
    if (_count > 0 && mounted) {
      setState(() {});
    }
    Global.songLists = await SongListProvider.queryAllWithoutSongs();
    if (Global.songLists.isNotEmpty && mounted) {
      setState(() {});
    }
    EasyLoading.dismiss();
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

///
/// 音乐播放任务
///
_audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
