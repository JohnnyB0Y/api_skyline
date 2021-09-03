//  define.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'dart:async';
import 'package:dio/dio.dart';

import '../verification/verify.dart';
import '../react/model.dart';
import 'manager.dart';
import 'response.dart';
import 'request.dart';

const String kDefaultAPIServiceKey = 'kDefaultAPIServiceKey';

enum APIEnvironment {
  /// 开发环境
  develop,
  /// 预发布环境
  releaseCandidate,
  /// 生产环境
  release
}

enum APIConnectivityStatus {
  /// WiFi: Device connected via Wi-Fi
  wifi,

  /// Mobile: Device connected to cellular network
  mobile,

  /// None: Device not connected to any network
  none
}

enum APICallType {
  /// GET、PUT、DELETE 是幂等的，也就说多次提交，不会改变资源数量。
  /// POST 是非幂等的，也就说多次提交，会产生多份资源；
  get,
  post,
  put,
  delete,

  head,
  patch,
}

enum APICallbackStatus {
  none, // 什么也没有发生，默认状态
  success, // 成功
  failure, // 失败，比较笼统
  timeout, // 请求超时
  cancel, // 用户取消
  badRequest, // 无效请求：400
  unauthorized, // 请求不包含身份验证令牌或身份验证令牌已过期：401
  forbidden, // 客户端没有访问所请求资源的权限：403
  notFound, // 未找到请求的资源：404，例如用户不存在，资源不存在
  denied, // 拒绝访问：409，例如，重复发送验证码被拒绝
  apiServiceUnregistered, // APIService 未注册到API类
  repetitionRequest, // API正在loading，重复请求

  beforeCalling, // 状态，开始请求前
  interceptedBeforeCalling, // 调用前网络请求被拦截
  afterCalling, // 状态，请求完成后
  interceptedAfterCalling, // 调用后网络请求被拦截

  httpCodeError, // http code 校验错误
  dataError, // 数据错误 or 数据格式错误
  paramError, // 参数错误
  reformerDataError, // 过滤数据出错
  networkError, // 网络连接问题
  serverError, // 服务端未知错误：500
  lastPageError, // 已经是最后一页的数据，无法加载更多数据
  exceptionError, // 程序错误，抛异常

}

/// API各种组装协议
abstract class APIAssembly {

  /// 配置请求信息并组装APIRequestOptions
  APIRequestOptions requestOptionsForAPIManager(APIManager manager);

  /// 数据转换并组装APIResponse
  APIResponse responseForAPIManager(APIManager manager, Response response);

  // 返回直接供APIManager使用的数据，也是方便Reformer处理的JSON数据
  Object? rawDataForAPIManager(APIManager manager);

  // 错误信息 data
  Object? errorDataForAPIManager(APIManager manager);

  // 最终的URL
  String finalURL(String baseURL, String apiMethod, [Map param]);

  // 连接超时时间
  int connectTimeout();

  // 接收数据超时时间
  int receiveTimeout();

  // 发送数据超时时间
  int sendTimeout();

}

// API请求代理
abstract class APICallDelegate {
  // 返回请求参数
  Map<String, Object>? apiCallParams(APIManager manager);

  // 请求成功回调
  apiCallbackSuccess(APIManager manager);
  // 请求失败回调
  apiCallbackFailure(APIManager manager);
}

// API数据处理代理
abstract class APIReformerDelegate {

  ReactModel reformDataToReactModel(APIManager manager, Object? data, [Object? obj]);

  List<ReactModel> reformDataToReactModels(APIManager manager, Object? data, [Object? obj]);

}

/// API参数与数据验证器
/// 使用后会替换掉APIManager内部的实现，但你仍可拿到APIManager直接调用内部实现。
abstract class APIVerifier {

  /// 验证回调数据是否合规
  VerifyResult? verifyCallbackData(APIManager manager, Object? data);

  /// 验证请求参数是否合规
  VerifyResult? verifyCallParams(APIManager manager, Map<String, Object>? params);

}

/// API生命周期拦截器
/// 使用后会替换掉APIManager内部的实现，但你仍可拿到APIManager直接调用内部实现。
abstract class APIInterceptor {

  /// API起飞前, 返回值为false即打断请求
  bool beforeCallingAPI(APIManager manager);

  /// API落地后, 返回值为false即打断回调
  bool afterCallingAPI(APIManager manager);

  /// API失败回调执行前，返回值为false即打断回调
  bool beforePerformApiCallbackFailure(APIManager manager);

  /// API失败回调执行后
  afterPerformApiCallbackFailure(APIManager manager);

  /// API成功回调执行前，返回值为false即打断回调
  bool beforePerformApiCallbackSuccess(APIManager manager);

  /// API成功回调执行后
  afterPerformApiCallbackSuccess(APIManager manager);

}

/// API请求会话管理者
abstract class APISessionManager<T> {
  /// 发起API请求
  Future<T> callAPIForAPIManager(APIManager manager, [dynamic obj]);

  /// 取消请求
  cancelAPIForAPIManager(APIManager manager, [dynamic obj]);

  /// 删除缓存
  Future<bool> deleteCacheForAPIManager(APIManager manager, [dynamic obj]);
  /// 删除所有缓存
  deleteAllCache(APIManager manager, [dynamic obj]);

  /// 检测网络状态
  Future<APIConnectivityStatus> checkConnectivityStatus();

  /// 监听网络状态变化，记得不使用时，取消订阅StreamSubscription！
  StreamSubscription onConnectivityStatusChanged(Function(APIConnectivityStatus status) listen);
  
}
