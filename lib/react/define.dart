//  define.dart
//
//
//  Created by JohnnyB0Y on 2020/5/11.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'package:flutter/material.dart';
import 'model.dart';
import '../api/manager.dart';

abstract class ReactModelSafeAccess {
  // base access
  setVal(dynamic value, String forKey);
  dynamic val(String forKey);

  /// safe access
  setNull(String forKey);

  // 数字
  setNum(Object? value, String forKey);
  num? numVal(String forKey);

  // 布尔值
  setBool(Object? value, String forKey);
  bool? boolVal(String forKey);

  // 字符串
  setStr(Object? value, String forKey);
  String? strVal(String forKey);

  // 图片数据
  setIconData(Object? value, String forKey);
  IconData? iconData(String forKey);

  /// 从 fromKey 拷贝数据到 toKey
  copyValFromKeyToKey(String fromKey, String toKey);

  /// 从 fromKey 迁移数据到 toKey，并把 fromKey 制 null。
  migratingValFromKeyToKey(String fromKey, String toKey);
}

abstract class ReactModelBuilder {

  // 创建 widget
  Widget? createWidget(ReactModel rm, {Object? obj});

  // 创建 reactModel
  ReactModel? createModel(Object data, {APIManager? manager, Object? obj});

}

typedef ReactWidgetBuilderFunction = Widget Function(
    BuildContext context,
    /// 传递的数据
    Map? params,
    /// 直接传递下来的child widget
    Widget? child);
