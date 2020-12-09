//  item.dart
//  demo
//
//  Created by JohnnyB0Y on 12/9/20.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//
import 'package:api_skyline/api_skyline.dart';

/// 数据列表
class ItemListAPIManager extends APIPagedManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/user/itemList';

  @override
  // TODO: implement apiCacheOptions
  APICacheOptions get apiCacheOptions => APICacheOptions.for15s();
}

/// 单个数据
class ItemAPIManager extends APIPagedManager {
  @override
  // TODO: implement apiCallType
  APICallType get apiCallType => APICallType.get;

  @override
  // TODO: implement apiPathName
  String get apiPathName => 'v1/user/item';

  @override
  // TODO: implement apiCacheOptions
  APICacheOptions get apiCacheOptions => APICacheOptions.for15s();
}
