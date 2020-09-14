import 'package:flutter/material.dart';
import 'package:hiphop_player/common/global.dart';

///
/// 列表页面
///
/// @author zzzz1997
/// @created_time 20200914
///
class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

///
/// 列表页面状态
///
class _ListPageState extends State<ListPage> {
  // 标签列表
  final _tabs = ['单曲', '歌手', '专辑'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.s.songList),
      ),
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(
              tabs: _tabs
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
