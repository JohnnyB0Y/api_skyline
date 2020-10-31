//  response.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'package:dio/dio.dart';

class APIResponse extends Response {
  int httpCode;
  /// 转换后的JSON对象
  Object bodyData;

  APIResponse(this.httpCode, this.bodyData);
}
