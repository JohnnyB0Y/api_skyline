//  widget.dart
//  see_app
//
//  Created by JohnnyB0Y on 2020/5/13.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'package:flutter/material.dart';
import 'model.dart';
import 'notice.dart';
import 'define.dart';
import '../api/manager.dart';
import '../api/hub.dart';
import '../api/define.dart';

typedef RebuildWidgetFunc = void Function(VoidCallback fn);

class ReactWidget extends StatefulWidget {

  // ---------------------- 接口
  /// API集合类
  final List<APIHub>? apiHubs;
  /// 返回请求参数
  final Map<String, Object> Function(APIManager manager)? onApiCallParams;
  /// 请求成功回调
  final Function(APIManager manager)? onApiCallSuccess;
  /// 请求失败回调
  final Function(APIManager manager)? onApiCallFailure;


  // ----------------------- 通知
  final ObservedDefaultNoticeCenter? observedDefaultNoticeCenter;

  // ----------------------- UI 部件
  /// 控件创建方法: (context, params, child) { }
  final ReactWidgetBuilderFunction? builder;
  /// 模型，小部件可以绑定刷新UI
  final ReactModel? binding;
  /// 展示的小部件
  final Widget? child;


  // ----------------------- 参数传递
  /// 取出传入的 ReactModel 的键s
  final List<CollectParam>? collectParams;
  /// 提供外界获取的 ReactModel键值对s
  final List<ProvideParam>? provideParams;


  /// 初始化状态时调用
  final Function()? initState;
  /// 销毁状态时调用
  final Function()? disposeState;
  final Function(ReactWidget oldWidget)? didUpdateWidget;


  const ReactWidget.builder({
    Key? key,

    this.apiHubs,
    this.onApiCallParams,
    this.onApiCallSuccess,
    this.onApiCallFailure,

    this.observedDefaultNoticeCenter,

    @required this.builder,
    this.binding,
    this.child,

    this.collectParams,
    this.provideParams,


    this.initState,
    this.disposeState,
    this.didUpdateWidget,

  }): assert(builder != null), super(key: key);

  
  const ReactWidget.apiHub({
    Key? key,

    @required this.apiHubs,
    this.onApiCallParams,
    this.onApiCallSuccess,
    this.onApiCallFailure,

    this.observedDefaultNoticeCenter,

    @required this.builder,
    this.binding,
    this.child,

    this.collectParams,
    this.provideParams,

    this.initState,
    this.disposeState,
    this.didUpdateWidget,

  }): assert(apiHubs != null), assert(builder != null), super(key: key);

  
  const ReactWidget.binding({
    Key? key,

    this.apiHubs,
    this.onApiCallParams,
    this.onApiCallSuccess,
    this.onApiCallFailure,

    this.observedDefaultNoticeCenter,

    @required this.builder,
    @required this.binding,
    this.child,

    this.collectParams,
    this.provideParams,

    this.initState,
    this.disposeState,
    this.didUpdateWidget,

  }): assert(binding != null), assert(builder != null), super(key: key);

  @override
  State<ReactWidget> createState() => _ReactWidgetState();
}


class _ReactWidgetState extends State<ReactWidget> implements APICallDelegate, NoticeObservable {

  static final Map<_ReactWidgetState, List<ProvideParam>> _provideParams = {};

  @override
  void initState() {
    super.initState();

    // 模型绑定UI
    widget.binding?.bindingWidgetFunc(rebuildWidget);
    // api 代理
    widget.apiHubs?.forEach((element) {
      element.callDelegate = this;
    });
    // 添加观察者
    widget.observedDefaultNoticeCenter?.observations.forEach((element) {
      NoticeCenter.defaultCenter().addObserver(this, element.name, element.cipher);
    });

    // 提供的参数
    if (widget.provideParams != null) {
      _provideParams[this] = widget.provideParams!;
    }

    if (widget.initState != null) {
      widget.initState!.call();
    }
  }

  @override
  void didUpdateWidget(ReactWidget oldWidget) {
    // 模型绑定UI
    widget.binding?.bindingWidgetFunc(rebuildWidget);
    // api 代理
    widget.apiHubs?.forEach((element) {
      element.callDelegate = this;
    });

    // 提供的参数
    if (widget.provideParams != null) {
      _provideParams[this] = widget.provideParams!;
    }
    else {
      _provideParams.remove(this);
    }

    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget!(oldWidget);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {

    // 移除绑定UI
    widget.binding?.unbindingWidgetFunc(rebuildWidget);

    // 移除观察者
    widget.observedDefaultNoticeCenter?.observations.forEach((element) {
      NoticeCenter.defaultCenter().removeObserver(this, element.name);
    });

    // 制空API代理
    widget.apiHubs?.forEach((element) {
      element.callDelegate = null;
    });

    // 移除提供的参数
    if (widget.provideParams != null) {
      _provideParams.remove(this);
    }

    if (widget.disposeState != null) {
      widget.disposeState!();
    }

    super.dispose();
  }

  // 重绘界面
  rebuildWidget(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {

    // 向上找数据
    Map? params = findCollectParams(widget.collectParams);
    return widget.builder!(context, params ?? {}, widget.child);
  }

  static Map? findCollectParams(List<CollectParam>? keys) {

    if (keys == null || keys.isEmpty) {
      return null;
    }

    List<List<ProvideParam>> data = _provideParams.values.toList();
    var length = data.length;
    if (length <= 0) {
      return null;
    }

    // 拿到去重的key
    Set<CollectParam> keySet = {};
    for (var key in keys) {
      keySet.add(key);
    }

    CollectParam? delKey;
    Map collectParams = {};

    for (int i = length-1; i<length; i--) {
      // 向上找！
      var provideParams = data[i];
      for (var collect in keySet) {
        for (int j = 0; j<provideParams.length; j++) {
          var provide = provideParams[j];

          if ((provide.key == collect.key) && (provide.cipher == collect.cipher)) {
            // 找到
            collectParams[collect.key] = provide.param;
            delKey = collect;
            break;
          }
        }
      }

      // 找完没？
      if (delKey != null) {
        // 移除找到的key
        if (keySet.length > 1) {
          keySet.remove(delKey);
          delKey = null;
        }
        else {
          // 找到并且是最后一个，直接结束。
          break;
        }
      }
    }

    return collectParams;
  }

  // -------------------- override
  @override
  Map<String, Object>? apiCallParams(APIManager manager) {
    if (widget.onApiCallParams != null) {
      return widget.onApiCallParams!(manager);
    }
    return null;
  }

  @override
  apiCallbackFailure(APIManager manager) {
    if (widget.onApiCallFailure != null) {
      widget.onApiCallFailure!(manager);
    }
  }

  @override
  apiCallbackSuccess(APIManager manager) {
    if (widget.onApiCallSuccess != null) {
      widget.onApiCallSuccess!(manager);
    }
  }

  @override
  observedNotice(Notice notice, NoticeCenter noticeCenter) {
    if (noticeCenter == NoticeCenter.defaultCenter()) {
      widget.observedDefaultNoticeCenter?.observedNotice(notice);
    }
  }
}
