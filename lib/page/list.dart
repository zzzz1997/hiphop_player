import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:hiphop_player/util/music_finder.dart';
import 'package:hiphop_player/widget/player_bar.dart';

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
  // 音乐列表
  var _songs = List<MediaItem>();

  // 是否搜索
  var _isSearch = false;

  // 已搜索
  var _searched = List<MediaItem>();

  // 是否多选模式
  var _isSelect = false;

  // 已选
  var _selected = List<int>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      EasyLoading.show();
      _songs = await MusicItemProvider.queryAll();
      if (_songs.isNotEmpty) {
        setState(() {});
      }
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: Scaffold(
        appBar: AppBar(
          title: _isSelect
              ? Text(Global.s.selectSong)
              : _isSearch
                  ? TextField(
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: Global.s.enterSongTitle,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        // border: const UnderlineInputBorder(
                        //   borderSide: BorderSide(
                        //     color: Colors.white,
                        //   ),
                        // ),
                        border: InputBorder.none,
                      ),
                      onChanged: (s) {
                        if (s.isNotEmpty) {
                          _searched = _songs
                              .where((element) => element.title.indexOf(s) > -1)
                              .toList();
                          setState(() {});
                        }
                      },
                    )
                  : Text(Global.s.songList),
          actions: [
            IconButton(
              icon: Icon(_isSelect
                  ? Icons.check
                  : _isSearch ? Icons.close : Icons.search),
              onPressed: () {
                if (_isSelect) {
                  _isSelect = false;
                } else {
                  _isSearch = !_isSearch;
                  _searched.clear();
                }
                setState(() {});
              },
            ),
          ],
        ),
        body: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                if (_songs.isNotEmpty) {
                  await AudioService.updateQueue(_songs);
                  await AudioService.skipToQueueItem(_songs[0].id);
                  await AudioService.play();
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.play_circle_outline),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(Global.s.playAll),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _songs.isEmpty
                  ? Center(
                      child: FlatButton(
                        child: Text(Global.s.noSongs),
                        onPressed: () async {
                          EasyLoading.show();
                          _songs = await MusicUtil.findSongs();
                          if (_songs.isNotEmpty) {
                            setState(() {});
                            MusicItemProvider.insertList(_songs);
                          }
                          EasyLoading.dismiss();
                        },
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (_, i) =>
                          _buildSong((_isSearch ? _searched : _songs)[i]),
                      itemCount: (_isSearch ? _searched : _songs).length,
                    ),
            ),
            PlayerBar(),
          ],
        ),
      ),
    );
  }

  ///
  /// 构建歌
  ///
  Widget _buildSong(MediaItem song) {
    var index = (_isSearch ? _searched : _songs).indexOf(song);
    var selected = _selected.contains(index);
    Widget icon = Icon(
      _isSelect
          ? selected ? Icons.check_circle : Icons.radio_button_unchecked
          : Icons.more_vert,
      color: _isSelect && selected
          ? Theme.of(context).accentColor
          : Theme.of(context).iconTheme.color,
    );
    if (_isSelect) {
      icon = IconButton(
        icon: icon,
        onPressed: null,
      );
    } else {
      icon = PopupMenuButton(
        icon: icon,
        itemBuilder: (_) => <PopupMenuItem<String>>[
          PopupMenuItem(
            value: '多选',
            child: Text("多选"),
          ),
          PopupMenuItem(
            value: '删除',
            child: Text("删除"),
          ),
        ],
        onSelected: (s) {
          switch (s) {
            case '多选':
              _isSelect = true;
              _selected = [index];
              setState(() {});
              break;
            case '删除':
              break;
            default:
              break;
          }
        },
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (_isSelect) {
          if (selected) {
            _selected.remove(index);
          } else {
            _selected.add(index);
            _selected.sort();
          }
          setState(() {});
          return;
        }
        var i = _songs.indexOf(song);
        var songs = _songs.sublist(i) + _songs.sublist(0, i);
        await AudioService.updateQueue(songs);
        await AudioService.skipToQueueItem(songs[0].id);
        await AudioService.play();
      },
      onLongPress: () {
        if (!_isSelect) {
          _isSelect = true;
          _selected = [index];
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Global.brightnessColor(context,
                          light: Style.greyColor),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32,
              child: icon,
            ),
          ],
        ),
      ),
    );
  }
}
