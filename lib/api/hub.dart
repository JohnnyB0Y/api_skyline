//  hub.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'define.dart';

typedef APIHubCallingFunc = void Function(APIHub hub, Function() next);

abstract class APIHub extends Object {

  // api 回调代理
  APICallDelegate callDelegate;

  /// 串行执行函数
  serialCalling(List<APIHubCallingFunc> functions) {
    _makeNextFunc(this, functions, 0).call();
  }

  _makeNextFunc(APIHub hub, List<APIHubCallingFunc> functions, idx) {
    if (idx < functions.length) {
      return () {
        functions[idx](hub, _makeNextFunc(hub, functions, 1 + idx));
      };
    }
    else {
      return () {};
    }
  }

  // 取消所有请求
  cancelAllAPIRequests() {

  }

}
