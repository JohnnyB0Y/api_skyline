//  model.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'package:flutter/material.dart';
import 'keys.dart';
import 'define.dart';
import 'notice.dart';
import 'widget.dart';

typedef I18nReactModelConfigFunc = dynamic Function(BuildContext context, dynamic key);

class ReactModel extends Object
    implements ReactModelSafeAccess
{

  final Map innerMap = Map();
  Map rawData;

  ReactModelBuilder _builder;
  Widget widget;

  // init
  ReactModel([Map map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
  }

  ReactModel.withWidget(this.widget, [Map map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
  }

  ReactModel.withBuilder(this._builder, [Map map]) {
    if (map != null) {
      innerMap.addAll(map);
    }
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
  bool conditionForKeys({List<String> trueKeys, List<String> falseKeys}) {
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
  setValForKeys(Object value, List<String> keys) {
    keys.forEach((key) {
      innerMap[key] = value;
    });
  }

  @override
  setVal(Object value, String forKey) {
    innerMap[forKey] = value;
  }

  @override
  Object val(String forKey) {
    return innerMap[forKey];
  }

  /// safe access
  @override
  setNull(String forKey) {
    innerMap[forKey] = null;
  }

  // 数字
  @override
  setNum(Object value, String forKey) {
    if (value is num) {
      innerMap[forKey] = value;
    }
  }

  @override
  num numVal(String forKey) {
    var value = innerMap[forKey];
    return (value is num) ? value : null;
  }

  // 布尔值
  @override
  bool boolVal(String forKey) {
    var value = innerMap[forKey];
    return (value is bool) ? value : null;
  }

  @override
  setBool(Object value, String forKey) {
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
  setStr(Object value, String forKey) {
    if (value is String) {
      innerMap[forKey] = value;
    }
  }

  @override
  String strVal(String forKey) {
    var value = innerMap[forKey];
    return (value is String) ? value : null;
  }

  // 图片数据
  @override
  setIconData(Object value, String forKey) {
    if (value is IconData) {
      innerMap[forKey] = value;
    }
  }

  @override
  IconData iconData(String forKey) {
    var value = innerMap[forKey];
    return (value is IconData) ? value : null;
  }

  // TODO --------------------- i18n ---------------------------
  static Map _globalReactModelFuncMap = Map();
  static configI18nGetterFunc(I18nReactModelConfigFunc func) {
    if (func != null) {
      _globalReactModelFuncMap[RMK.i18nGetterFunc] = func;
    }
  }

  static dynamic i18nVal(BuildContext context, dynamic i18nKey) {
    I18nReactModelConfigFunc func = _globalReactModelFuncMap[RMK.i18nGetterFunc];
    return func?.call(context, i18nKey);
  }
  
  setI18nVal(BuildContext context, dynamic i18nKey, String forKey) {
    innerMap[forKey] = i18nVal(context, i18nKey);
  }

  // TODO --------------------- UI Operation ---------------------------
  /// 创建Widget
  /// reuse 默认为 false，每次调用，builder都会重新创建Widget。
  /// reuse 指定为 true，每次调用，会检测成员变量 widget 是否有值，没有就创建，有直接返回。
  Widget createWidget({bool reuse = false}) {
    if (reuse) {
      if (widget == null) {
        widget = _builder?.createWidget(this);
      }
      return widget;
    }

    return _builder?.createWidget(this) ?? widget;
  }

  final Set<RebuildWidgetFunc> _rebuildWidgetFuncSet = Set();
  bindingWidgetFunc(RebuildWidgetFunc func) {
    if (func != null) {
      _rebuildWidgetFuncSet.add(func);
    }
  }

  unbindingWidgetFunc(RebuildWidgetFunc func) {
    if (func != null) {
      _rebuildWidgetFuncSet.remove(func);
    }
  }

  unbindingAllWidgetFunc() {
    _rebuildWidgetFuncSet.clear();
  }

  /// 刷新UI，重建Widget。
  refreshUI() {
    refreshUIByUpdateModel(null);
  }

  /// 更新模型数据并刷新UI，重建Widget。
  refreshUIByUpdateModel(Function(ReactModel model) func) {
    // 更新模型数据
    func?.call(this);
    // 刷新UI
    _rebuildWidgetFuncSet.forEach((rebuildWidgetFunc) {
      rebuildWidgetFunc.call((){});
    });
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
  Function(Notice notice) observedEventNotice;

  postEventNotice(Notice notice) {
    observedEventNotice?.call(notice);
  }

  postEventNoticeForName(String name, {dynamic context}) {
    postEventNotice(Notice(
      name: name,
      context: context,
      rm: this,
    ));
  }

}

/// 向父节点收集数据的 key
class CollectParam {
  final String key;
  final dynamic cipher;

  CollectParam({@required this.key, this.cipher});
}

/// 向子节点提供的数据
class ProvideParam {
  final String key;
  final dynamic param;
  final dynamic cipher;

  ProvideParam({@required this.key, @required this.param, this.cipher});
}

