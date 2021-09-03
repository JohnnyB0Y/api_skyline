//  notice.dart
//  see_app
//
//  Created by JohnnyB0Y on 2020/5/16.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'model.dart';

abstract class NoticeObservable {

  observedNotice(Notice notice, NoticeCenter noticeCenter);

}

/// 通告
class Notice {
  final String name;
  final dynamic context;
  final ReactModel? rm;
  
  Notice({required this.name, this.context, this.rm});
}

class Observation {
  /// 订阅通知的名称
  final String name;
  /// 发送与接收通知之间约定的暗号
  final dynamic cipher;

  Observation({required this.name, required this.cipher});
}

/// 观察者模型
class Observer {
  final String? name;
  final dynamic cipher;
  final NoticeObservable observer;

  Observer({required this.observer, this.name, this.cipher});
}

/// 通告中心
class NoticeCenter {

  NoticeCenter();

  // 单例
  factory NoticeCenter.defaultCenter() {
    if (_instance == null) {
      _instance = NoticeCenter();
    }
    return _instance!;
  }
  static NoticeCenter? _instance;

  final Map<String, List<Observer>> observers = Map();


  /// 添加观察者
  /// observer实现NoticeObservable协议的观察者
  /// forName 通知名称
  /// cipher 通知发送方和接收方约定的暗号，对上了才可收到通知
  bool addObserver(NoticeObservable observer, String forName, [cipher]) {
    // 取出观察者列表
    List<Observer>? list = observers[forName];

    if (list == null) {
      list = [];
      observers[forName] = list;
    }
    else { // 排除重复
      for (var om in list) {
        if (observer == om.observer) {
          return false;
        }
      }
    }

    // 添加观察者
    Observer om = Observer(observer: observer ,name: forName, cipher: cipher);
    list.add(om);

    return true;
  }

  /// 发出自定义通知
  /// notice 当你想自定义发送数据时使用
  /// cipher 通知发送方和接收方的暗号，对上了才可收到通知
  postNotice(Notice notice, String forName, [cipher]) {
    List<Observer>? list = observers[forName];
    if (list == null || list.isEmpty) {
      return;
    }

    for (int i = 0; i<list.length; i++) {
      Observer om = list[i];
      if (om.cipher == cipher) {
        // 通知
        om.observer.observedNotice(notice, this);
      }
    }
  }

  postNoticeForName(String name, dynamic context, ReactModel rm, [cipher]) {
    var notice = Notice(name: name, context: context, rm: rm);
    postNotice(notice, name, cipher);
  }

  /// 移除通知
  /// observer 观察者
  /// forName 通知名称
  removeObserver(NoticeObservable observer, String forName) {
    List<Observer> list = observers[forName] ?? [];
    int index = -1;

    for (int i = 0; i<list.length; i++) {
      if (list[i].observer == observer) {
        index = i;
        break;
      }
    }

    if (index != -1) {
      list.removeAt(index);
    }
  }

  removeAllObservers() {
    observers.clear();
  }

}

class ObservedDefaultNoticeCenter {

  final List<Observation> observations;
  final Function(Notice notice) observedNotice;
  ObservedDefaultNoticeCenter({required this.observations, required this.observedNotice});

}

