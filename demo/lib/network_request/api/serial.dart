//  serial.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 1/21/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//
import 'package:api_skyline/api_skyline.dart';

/// 依赖 1
class Depend1APIManager extends APIManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/sync/1';

  @override
  bool beforeCallingAPI(APIManager manager) {
    // TODO: implement beforeCallingAPI
    // 模拟请求成功 !!!!!
    manager.callbackStatus = APICallbackStatus.success;
    return false;
  }
}

/// 依赖 2
class Depend2APIManager extends APIManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/sync/2';

  @override
  bool beforeCallingAPI(APIManager manager) {
    // TODO: implement beforeCallingAPI
    // 模拟请求成功 !!!!!
    manager.callbackStatus = APICallbackStatus.success;
    return false;
  }
}

/// 依赖 3
class Depend3APIManager extends APIManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/sync/3';

  @override
  bool beforeCallingAPI(APIManager manager) {
    // TODO: implement beforeCallingAPI
    // 模拟请求成功 !!!!!
    manager.callbackStatus = APICallbackStatus.success;
    return false;
  }
}

/// 最终
class FinalAPIManager extends APIManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/sync/final';

  @override
  bool beforeCallingAPI(APIManager manager) {
    // TODO: implement beforeCallingAPI
    // 模拟请求成功 !!!!!
    manager.callbackStatus = APICallbackStatus.success;
    return false;
  }
}
