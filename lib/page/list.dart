import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hiphop_player/common/global.dart';
import 'package:hiphop_player/common/resource.dart';
import 'package:hiphop_player/entity/song_list.dart';
import 'package:hiphop_player/sqflite/provider/music_item.dart';
import 'package:hiphop_player/sqflite/provider/song_list.dart';
import 'package:hiphop_player/util/music_finder.dart';
import 'package:hiphop_player/widget/player_bar.dart';
import 'package:hiphop_player/widget/song_item.dart';
import 'package:hiphop_player/widget/song_list.dart';
import 'package:oktoast/oktoast.dart';

///
/// 列表页面
///
/// @author zzzz1997
/// @created_time 20200914
///
class ListPage extends StatefulWidget {
  // 歌单id
  final int id;

  ListPage(this.id);

  @override
  _ListPageState createState() => _ListPageState();
}

///
/// 列表页面状态
///
class _ListPageState extends State<ListPage> {
  // 歌单
  SongList _songList;

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
      if (widget.id == null) {
        _songs = await MusicItemProvider.queryAll();
      } else {
        _songList = await SongListProvider.query(widget.id);
        _songs = _songList.songs;
      }
      if (_songs.isNotEmpty) {
        setState(() {});
      }
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    var songs = _isSearch ? _searched : _songs;
    var selectedAll = _selected.length == songs.length;
    return AudioServiceWidget(
      child: WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            leading: _isSelect
                ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _isSelect = false;
                      setState(() {});
                    },
                  )
                : null,
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
                                .where(
                                    (element) => element.title.indexOf(s) > -1)
                                .toList();
                            setState(() {});
                          }
                        },
                      )
                    : Text(widget.id == null
                        ? Global.s.songList
                        : _songList?.name ?? ''),
            actions: [
              IconButton(
                icon: Icon(_isSelect
                    ? selectedAll ? Icons.clear_all : Icons.select_all
                    : _isSearch ? Icons.close : Icons.search),
                onPressed: () async {
                  if (_isSelect) {
                    _selected.clear();
                    if (!selectedAll) {
                      for (var i = 0; i < songs.length; i++) {
                        _selected.add(i);
                      }
                    }
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
              if (!_isSearch)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    SongItem.playSongs(_songs);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 5),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.play_circle_outline),
                        const SizedBox(
                          width: 5,
                        ),
                        Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: Global.s.playAll,
                              ),
                              TextSpan(
                                text: ' (${_songs.length}${Global.s.songs})',
                                style: TextStyle(
                                  color: Style.greyColor,
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
              _isSelect ? _buildSelectBar() : PlayerBar(),
            ],
          ),
        ),
        onWillPop: () {
          if (_isSelect || _isSearch) {
            if (_isSelect) {
              _isSelect = false;
            } else {
              _isSearch = false;
            }
            setState(() {});
            return Future.value(false);
          }
          return Future.value(true);
        },
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
            value: '收藏',
            child: Text(Global.s.collect),
          ),
          PopupMenuItem(
            value: '多选',
            child: Text(Global.s.multipleChoice),
          ),
          PopupMenuItem(
            value: '删除',
            child: Text(Global.s.delete),
          ),
        ],
        onSelected: (s) {
          switch (s) {
            case '收藏':
              showSongListDialog(context, [song]);
              break;
            case '多选':
              _isSelect = true;
              _selected = [index];
              setState(() {});
              break;
            case '删除':
              _deleteSongs([song]);
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

  ///
  /// 构架选择栏
  ///
  Widget _buildSelectBar() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Style.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildIconButton(Icons.play_circle_outline, Global.s.play, () {
            var songs = _isSearch ? _searched : _songs;
            SongItem.playSongs(_selected.map((e) => songs[e]).toList());
            _isSelect = false;
            setState(() {});
          }),
          _buildIconButton(Icons.add_circle_outline, Global.s.addToSongList,
              () async {
            if (_selected.isNotEmpty) {
              var songs = _isSearch ? _searched : _songs;
              var b = await showSongListDialog(
                  context, _selected.map((e) => songs[e]).toList());
              if (b == null || !b) {
                return;
              }
            }
            _isSelect = false;
            setState(() {});
          }),
          _buildIconButton(Icons.delete_outline, Global.s.delete, () {
            var songs = _isSearch ? _searched : _songs;
            _deleteSongs(_selected.map((e) => songs[e]).toList());
          }),
        ],
      ),
    );
  }

  ///
  /// 构建图标按钮
  ///
  Widget _buildIconButton(IconData iconData, String text, Function onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData),
            Text(text),
          ],
        ),
      ),
    );
  }

  ///
  /// 删除歌曲
  ///
  _deleteSongs(List<MediaItem> songs) async {
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
              _songs.removeWhere((element) => songs.contains(element));
              try {
                if (widget.id == null) {
                  await MusicItemProvider.delete(
                      songs.map((e) => e.id).toList());
                } else {
                  _songList.songs = _songs;
                  _songList.number = _songList.songs.length;
                  _songList.cover = _songList.songs[0].artUri;
                  await SongListProvider.update(_songList);
                }
                Global.navigator.pop();
                _isSelect = false;
                setState(() {});
              } catch (e) {
                showToast(e.toString());
              }
            },
            child: Text(Global.s.delete),
          ),
        ],
      ),
    );
  }
}
