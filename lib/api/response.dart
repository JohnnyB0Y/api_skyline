//  response.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

class APIResponse {
  int httpCode;
  /// 转换后的JSON对象
  Object? bodyData;

  APIResponse(this.httpCode, this.bodyData);
}
