//  hub.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'define.dart';

abstract class APIHub extends Object {

  // api 回调代理
  APICallDelegate callDelegate;



  // 取消所有请求
  cancelAllAPIRequests() {

  }

//  // 子类重写，初始化APIManager 和 APIReformer
//  configAPIs ();

}
