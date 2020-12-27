// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `en`
  String get _locale {
    return Intl.message(
      'en',
      name: '_locale',
      desc: '',
      args: [],
    );
  }

  /// `Hiphop player`
  String get appName {
    return Intl.message(
      'Hiphop player',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `Song list`
  String get songList {
    return Intl.message(
      'Song list',
      name: 'songList',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Color theme`
  String get colorTheme {
    return Intl.message(
      'Color theme',
      name: 'colorTheme',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Font`
  String get font {
    return Intl.message(
      'Font',
      name: 'font',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get autoBySystem {
    return Intl.message(
      'Auto',
      name: 'autoBySystem',
      desc: '',
      args: [],
    );
  }

  /// `ZCOOL KuaiLe`
  String get fontKuaiLe {
    return Intl.message(
      'ZCOOL KuaiLe',
      name: 'fontKuaiLe',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `Music`
  String get music {
    return Intl.message(
      'Music',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `No songs, search local`
  String get noSongs {
    return Intl.message(
      'No songs, search local',
      name: 'noSongs',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Play all`
  String get playAll {
    return Intl.message(
      'Play all',
      name: 'playAll',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the song title`
  String get enterSongTitle {
    return Intl.message(
      'Please enter the song title',
      name: 'enterSongTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select song`
  String get selectSong {
    return Intl.message(
      'Select song',
      name: 'selectSong',
      desc: '',
      args: [],
    );
  }

  /// `Multiple choice`
  String get multipleChoice {
    return Intl.message(
      'Multiple choice',
      name: 'multipleChoice',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Current play`
  String get currentPlay {
    return Intl.message(
      'Current play',
      name: 'currentPlay',
      desc: '',
      args: [],
    );
  }

  /// `Collect`
  String get collect {
    return Intl.message(
      'Collect',
      name: 'collect',
      desc: '',
      args: [],
    );
  }

  /// `Collect all`
  String get collectAll {
    return Intl.message(
      'Collect all',
      name: 'collectAll',
      desc: '',
      args: [],
    );
  }

  /// `Collect to song list`
  String get collectToSongList {
    return Intl.message(
      'Collect to song list',
      name: 'collectToSongList',
      desc: '',
      args: [],
    );
  }

  /// `New song list`
  String get newSongList {
    return Intl.message(
      'New song list',
      name: 'newSongList',
      desc: '',
      args: [],
    );
  }

  /// `Please input song list title`
  String get inputSongListTitle {
    return Intl.message(
      'Please input song list title',
      name: 'inputSongListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Conform`
  String get conform {
    return Intl.message(
      'Conform',
      name: 'conform',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Song list added success`
  String get songListAddedSuccess {
    return Intl.message(
      'Song list added success',
      name: 'songListAddedSuccess',
      desc: '',
      args: [],
    );
  }

  /// ` songs`
  String get songs {
    return Intl.message(
      ' songs',
      name: 'songs',
      desc: '',
      args: [],
    );
  }

  /// `No playback`
  String get noPlayback {
    return Intl.message(
      'No playback',
      name: 'noPlayback',
      desc: '',
      args: [],
    );
  }

  /// `Unknown singer`
  String get unknownSinger {
    return Intl.message(
      'Unknown singer',
      name: 'unknownSinger',
      desc: '',
      args: [],
    );
  }

  /// `Song already exists`
  String get songAlreadyExists {
    return Intl.message(
      'Song already exists',
      name: 'songAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `Collected to song list`
  String get collectedToSongList {
    return Intl.message(
      'Collected to song list',
      name: 'collectedToSongList',
      desc: '',
      args: [],
    );
  }

  /// `Edit info`
  String get editInfo {
    return Intl.message(
      'Edit info',
      name: 'editInfo',
      desc: '',
      args: [],
    );
  }

  /// `Add to song list`
  String get addToSongList {
    return Intl.message(
      'Add to song list',
      name: 'addToSongList',
      desc: '',
      args: [],
    );
  }

  /// `Conform delete this song list?`
  String get conformDeleteSongList {
    return Intl.message(
      'Conform delete this song list?',
      name: 'conformDeleteSongList',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}