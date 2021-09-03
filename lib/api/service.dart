//  service.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  APIService 映射的是一台域名服务器，或者一套约定规则的API接口
//  这样抽象的好处是，1）区分运行环境调试；2）对共用、重复的部分进行统一处理；
//  3）一个app有多个域名服务器要访问的时候可以单独处理，各自维护自己的链接；

import 'dart:convert';

import 'package:dio/dio.dart';
import '../verification/verify.dart';
import 'session.dart';

import 'response.dart';
import 'request.dart';
import 'config.dart';
import 'manager.dart';
import 'define.dart';


abstract class APIService extends Object implements APIAssembly {

  // APP 运行模式
  final bool isDebugMode = ! bool.fromEnvironment("dart.vm.product");
  // API 运行环境
  APIEnvironment environment = APIEnvironment.develop;
  // 请求头
  Map<String, String> headers = Map();
  // 公共请求参数
  Map<String, dynamic> commonParams = Map();
  // 真实的网络请求类
  APISessionManager sessionManager = APIDefaultSessionManager();

  // URL 前缀
  String get baseURL;

  // 校验HTTP状态码
  VerifyResult? verifyHTTPCode(APIManager manager, int code);

  // 全局错误，处理成功 返回 true 就不调用callback函数了，处理失败返回 false 继续往下走。
  // 当 exception != null，是抛异常才走到这里
  bool handleGlobalError(APIManager manager, VerifyResult? error, dynamic exception);

  // 配置分页参数（分页处理）
  configPagedParams(APIPagedManager manager, Map<String, Object> params);

  // 是否最后一页（分页处理）
  bool isTheLastPageForAPIManager(APIPagedManager manager);

  // -------------- API 组装相关
  /// 返回请求配置
  @override
  APIRequestOptions requestOptionsForAPIManager(APIManager manager) {

    Map<String, dynamic> finalParams = manager.clientParams;
    finalParams.addAll(this.commonParams);

    Map<String, dynamic> queryParams = {};
    Map data = {};
    switch (manager.apiCallType) {
      case APICallType.get:
        queryParams = finalParams;
        break;
      case APICallType.post:
        data = finalParams;
        break;
      case APICallType.put:
        data = finalParams;
        break;
      case APICallType.delete:
        queryParams = finalParams;
        break;
      case APICallType.head:
        queryParams = finalParams;
        break;
      case APICallType.patch:
        data = finalParams;
        break;
    }

    APIRequestOptions options = APIRequestOptions(
      headers: this.headers,
      method: manager.apiMethod,
      baseUrl: baseURL,
      queryParams: queryParams,
      data: data,
      connectTimeout: manager.connectTimeout(),
      receiveTimeout: manager.receiveTimeout(),
      sendTimeout: manager.sendTimeout(),
      validateStatus: (code) => true,

    );
    return options;
  }

  // 数据转换并组装
  @override
  APIResponse responseForAPIManager(APIManager manager, Response? response) {

    if (response == null) {
      return APIResponse(-1, null);
    }

    var bodyData;
    if (response.data is Map || response.data is List) {
      bodyData = response.data;
    }
    else if (response.data is String) {
      try {
        bodyData = JsonDecoder().convert(response.data);
      }
      catch (e) {
        manager.callbackStatus = APICallbackStatus.dataError;
        print('数据转换错误：$e');
      }
    }
    return APIResponse(response.statusCode ?? -1, bodyData);
  }

  @override
  Object? rawDataForAPIManager(APIManager manager) {
    return manager.response?.bodyData;
  }

  @override
  Object? errorDataForAPIManager(APIManager manager) {
    return manager.response?.bodyData;
  }

  @override
  String finalURL(String baseURL, String apiMethod, [Map? param]) {

    String finalURL = baseURL + apiMethod;
    if (param != null && param.isNotEmpty) {
      String queryUrl = '?';
      int i = 0;
      param.forEach((k, v){
        if (i == 0)
          queryUrl += k + '=' + v.toString();
        else
          queryUrl += '&' + k + '=' + v.toString();
        i++;
      });

      return finalURL + queryUrl;
    }

    return finalURL;
  }

  // 连接超时时间
  @override
  int connectTimeout() {
    return 6000;
  }

  // 接收数据超时时间
  @override
  int receiveTimeout() {
    return 6000;
  }

  // 发送数据超时时间
  @override
  int sendTimeout() {
    return 12000;
  }

  // config basic authorization
  configAuthorization(String? username, String? password) {
    username = username ?? '';
    password = password ?? '';
    var bytes = utf8.encode(username + ':' + password);
    this.headers['Authorization'] = 'Basic ${base64.encode(bytes)}';
  }

  // config request headers
  configRequestHeaders(String key, String value) {
    this.headers[key] = value;
  }

  // 注册初始化
  registerForKey(String key) {
    APIConfig.registerAPIServiceForKey(key, this);
  }

  registerForDefault() {
    APIConfig.registerDefaultAPIService(this);
  }

}
