import 'dart:io';

import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';

///
/// 矢量图标
///
/// @author zzzz1997
/// @created_time 20200115
///
class IconFonts {
  // 图标库名
  static const String _fontFamily = 'fluzz';

  // fluzz图标
  static const IconData album = IconData(0xe609, fontFamily: _fontFamily);
}

///
/// 图片帮助类
///
class ImageHelper {
  ///
  /// 图片链接
  ///
  static String image(String name) => 'assets/images/$name';

  ///
  /// 网络图片
  ///
  static ExtendedImage networkImage(String url,
      {double width, double height, BoxFit fit, BoxShape shape}) {
    return ExtendedImage.network(
      url,
      width: width,
      height: height,
      fit: fit,
      shape: shape,
      loadStateChanged: (ExtendedImageState s) =>
          s.extendedImageLoadState == LoadState.loading
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                )
              : s.extendedImageLoadState == LoadState.failed
                  ? Center(
                      child: Icon(Icons.error_outline),
                    )
                  : null,
    );
  }

  ///
  /// 本地资源图片
  ///
  static ExtendedImage assetImage(String name,
      {double width, double height, BoxFit fit, BoxShape shape}) {
    return ExtendedImage.asset(
      image(name),
      width: width,
      height: height,
      fit: fit,
      shape: shape,
    );
  }

  ///
  /// 文件图片
  ///
  static ExtendedImage fileImage(File file,
      {double width, double height, BoxFit fit, BoxShape shape}) {
    return ExtendedImage.file(
      file,
      width: width,
      height: height,
      fit: fit,
      shape: shape,
    );
  }

  ///
  /// 本地资源图片提供者
  ///
  static ImageProvider assetImageProvider(String name) {
    return AssetImage(image(name));
  }
}

///
///
/// 样式
class Style {
  // 灰色
  static const greyColor = Colors.grey;

  // 分割线
  static const dividerColor = Color(0xFFF1F1F1);
}
