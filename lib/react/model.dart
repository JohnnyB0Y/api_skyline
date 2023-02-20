//  model.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'dart:convert';
import 'package:flutter/material.dart';
import 'define.dart';
import 'notice.dart';
import 'widget.dart';

class ReactModel extends Object
    implements ReactModelSafeAccess
{

  final Map innerMap = {};
  Map? rawData;

  ReactModelBuilder? _builder;
  Widget? widget;

  // init
  ReactModel([Map? map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
  }

  ReactModel.withWidget(this.widget, [Map? map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
  }

  ReactModel.withBuilder(this._builder, [Map? map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
  }

  /// 从 Json字符串反序列数据，并添加到innerMap中
  ReactModel.withJsonData(String jsonData) {
    innerMap.addAll(json.decode(jsonData));
  }

  /// 序列化内部字典为Json字符串
  String encodeInnerMap() {
    return json.encode(innerMap);
  }

  /// 从 fromKey 拷贝数据到 toKey
  @override
  void copyValFromKeyToKey(String fromKey, String toKey) {
    setVal(val(fromKey), toKey);
  }

  /// 从 fromKey 迁移数据到 toKey，并把 fromKey 制 null。
  @override
  void migratingValFromKeyToKey(String fromKey, String toKey) {
    setVal(val(fromKey), toKey);
    setNull(fromKey);
  }

  /// 只有当 key 的 value == true 时，返回 true
  bool conditionForKey(String key) {
    var val = innerMap[key];
    if (val is bool) {
      return val;
    }
    return false;
  }

  /// trueKeys 的 value 都为 true ？falseKeys 的 value 都为 false ？
  bool conditionForKeys({required List<String> trueKeys, required List<String> falseKeys}) {
    return trueForKeys(trueKeys) && falseForKeys(falseKeys);
  }

  /// keys 的 value 都为 true ？
  bool trueForKeys(List<String> keys) {
    for (int i=0; i<keys.length; i++) {
      var key = keys[i];
      if (conditionForKey(key) == false) {
        return false;
      }
    }
    return true;
  }

  /// keys 的 value 都为 false ？
  bool falseForKeys(List<String> keys) {
    for (int i=0; i<keys.length; i++) {
      var key = keys[i];
      if (conditionForKey(key) == true) {
        return false;
      }
    }
    return true;
  }

  // public method
  void setValForKeys(dynamic value, List<String> keys) {
    for (var key in keys) {
      innerMap[key] = value;
    }
  }

  @override
  void setVal(dynamic value, String forKey) {
    innerMap[forKey] = value;
  }

  @override
  dynamic val(String forKey) {
    return innerMap[forKey];
  }

  /// 设 null
  @override
  void setNull(String forKey) {
    innerMap[forKey] = null;
  }

  // 数字
  @override
  void setNum(dynamic value, String forKey) {
    if (value is num) {
      innerMap[forKey] = value;
    }
  }

  /// 增加数值
  num increaseNum(num value, String forKey) {
    var old = numVal(forKey);
    var cur = old == null ? value : value + old;
    setNum(cur, forKey);
    return cur;
  }

  /// 减少数值
  num decreaseNum(num value, String forKey) {
    var old = numVal(forKey);
    var cur = old == null ? 0 - value : old - value;
    setNum(cur, forKey);
    return cur;
  }

  @override
  num? numVal(String forKey) {
    var value = innerMap[forKey];
    return (value is num) ? value : null;
  }

  // 布尔值
  @override
  bool? boolVal(String forKey) {
    var value = innerMap[forKey];
    return (value is bool) ? value : null;
  }

  @override
  void setBool(dynamic value, String forKey) {
    if (value is bool) {
      innerMap[forKey] = value;
    }
  }

  /// 安全获取布尔值，值为null时返回false
  bool safeBoolVal(String forKey) {
    var value = innerMap[forKey];
    return (value is bool) ? value : false;
  }

  // 字符串
  @override
  void setStr(dynamic value, String forKey) {
    if (value is String) {
      innerMap[forKey] = value;
    }
  }

  @override
  String? strVal(String forKey) {
    var value = innerMap[forKey];
    return (value is String) ? value : null;
  }

  // 图片数据
  @override
  void setIconData(dynamic value, String forKey) {
    if (value is IconData) {
      innerMap[forKey] = value;
    }
  }

  @override
  IconData? iconData(String forKey) {
    var value = innerMap[forKey];
    return (value is IconData) ? value : null;
  }

  // TODO --------------------- UI Operation ---------------------------
  /// 创建Widget
  /// reuse 默认为 false，每次调用，builder都会重新创建Widget。
  /// reuse 指定为 true，每次调用，会检测成员变量 widget 是否有值，没有就创建，有直接返回。
  Widget createWidget({bool reuse = false}) {
    if (reuse) {
      widget ??= _builder?.createWidget(this);
      return widget!;
    }

    return _builder?.createWidget(this) ?? widget!;
  }

  final Set<RebuildWidgetFunc> _rebuildWidgetFuncSet = {};
  void bindingWidgetFunc(RebuildWidgetFunc func) {
    _rebuildWidgetFuncSet.add(func);
  }

  void unbindingWidgetFunc(RebuildWidgetFunc func) {
    _rebuildWidgetFuncSet.remove(func);
  }

  void unbindingAllWidgetFunc() {
    _rebuildWidgetFuncSet.clear();
  }

  /// 刷新UI，重建Widget。
  void refreshUI() {
    refreshUIByUpdateModel(null);
  }

  /// 更新模型数据并刷新UI，重建Widget。
  void refreshUIByUpdateModel(Function(ReactModel model)? func) {
    // 更新模型数据
    func?.call(this);
    // 刷新UI
    for (var rebuildWidgetFunc in _rebuildWidgetFuncSet) {
      rebuildWidgetFunc.call((){});
    }
  }

  ReactModel copy([bool onlyData = true]) {
    ReactModel rm;
    if (onlyData) {
      rm = ReactModel(innerMap);
    }
    else {
      rm = ReactModel.withBuilder(_builder, innerMap);
      rm.widget = widget;
    }
    return rm;
  }

  // TODO --------------------- post & observed event ---------------------------
  void Function(Notice notice)? observedEventNotice;

  // TODO --------------------- Closure ---------------------------
  final Map _reactClosureFuncMap = {};

}

// todo ------------------------- 通知分类
extension Notification on ReactModel {
  /// 发送通知
  void postEventNotice(Notice notice) {
    observedEventNotice?.call(notice);
  }

  /// 发送通知
  void postEventNoticeForName(String name, {dynamic context}) {
    postEventNotice(Notice(
      name: name,
      context: context,
      rm: this,
    ));
  }
}

// todo ------------------------- 闭包分类
typedef ReactClosureFunc = dynamic Function(ReactModel model, String key, dynamic ctx);

/// 响应闭包
class ReactClosure {
  bool isExecutable;
  ReactClosureFunc func;

  ReactClosure(this.func, this.isExecutable);
}

extension Closure on ReactModel {
  /// 添加闭包函数
  void setClosureFunc(ReactClosureFunc func, String forKey) {
    setClosure(ReactClosure(func, true), forKey);
  }

  /// 添加闭包对象
  void setClosure(ReactClosure closure, String forKey) {
    closure.isExecutable = true;
    _reactClosureFuncMap[forKey] = closure;
  }

  /// 移除闭包对象
  ReactClosure? removeClosure(String forKey) {
    return _reactClosureFuncMap.remove(forKey);
  }

  /// 移除所有闭包
  void clearAllClosure() {
    _reactClosureFuncMap.clear();
  }

  /// 取出闭包对象
  ReactClosure? closure(String forKey) {
    return _reactClosureFuncMap[forKey];
  }

  /// 设置闭包为可执行
  void setClosureNeedsExecute(String forKey) {
    closure(forKey)?.isExecutable = true;
  }

  /// 强制执行闭包，返回执行结果
  dynamic executeClosure(String forKey, [dynamic ctx]) {
    setClosureNeedsExecute(forKey);
    return executeClosureIfNeeded(forKey, ctx);
  }

  /// 执行闭包并获得结果，如果需要的话（可以保证闭包不重复执行，结果会存储）
  dynamic executeClosureIfNeeded(String forKey, [dynamic ctx]) {
    var c = closure(forKey);
    if (c != null && c.isExecutable) {
      innerMap[forKey] = c.func(this, forKey, ctx); // 存储计算结果
      c.isExecutable = false;
    }
    return innerMap[forKey];
  }

}


/// 向父节点收集数据的 key
class CollectParam {
  final String key;
  final dynamic cipher;

  CollectParam({required this.key, this.cipher});
}

/// 向子节点提供的数据
class ProvideParam {
  final String key;
  final dynamic param;
  final dynamic cipher;

  ProvideParam({required this.key, required this.param, this.cipher});
}
