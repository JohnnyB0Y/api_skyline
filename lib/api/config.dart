//  config.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'service.dart';
import 'define.dart';

class APIConfig {

  static Map<String, APIService> apiServices = Map();

  static registerAPIServiceForKey(String key, APIService service) {
    apiServices[key] = service;
  }

  static registerDefaultAPIService(APIService service) {
    APIConfig.registerAPIServiceForKey(kDefaultAPIServiceKey, service);
  }

  static APIService dequeueAPIServiceForKey(String key) {
    return apiServices[key];
  }

  static APIService dequeueDefaultAPIService() {
    return apiServices[kDefaultAPIServiceKey];
  }

}
