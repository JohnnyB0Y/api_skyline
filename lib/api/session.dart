//  session.dart
//  see_app
//
//  Created by JohnnyB0Y on 2020/5/18.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'dart:async';
import 'define.dart';
import 'manager.dart';
import 'request.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:connectivity/connectivity.dart';

class APIDefaultSessionManager implements APISessionManager {

  // dio 网络请求
  Dio? _dio;
  Dio get dio {
    _dio ??= Dio();
    return _dio!;
  }

  CacheConfig? _cacheConfig;
  DioCacheManager? _cacheManager;

  @override
  Future<Response> callAPIForAPIManager(APIManager manager, [obj]) async {

    APIRequestOptions options = manager.requestOptionsForAPIManager(manager);

    // 缓存配置
    if (_cacheConfig?.baseUrl != options.baseUrl) {
      _cacheConfig = CacheConfig(baseUrl: options.baseUrl,);
      _cacheManager = DioCacheManager(_cacheConfig!);
      dio.interceptors.add(_cacheManager?.interceptor);
    }

    // 取消请求的token
    manager.cancelToken ??= CancelToken();

    // 发起请求
    dio.options.baseUrl = options.baseUrl;
    Response response = await dio.request(
      manager.apiPathName,
      queryParameters: options.queryParams,
      data: options.data,
      options: _buildCacheOptions(manager, options),
      cancelToken: manager.cancelToken,
    );

    return response;
  }

  /// 取消网络请求
  @override
  cancelAPIForAPIManager(APIManager manager, [obj]) {
    if (manager.cancelToken is CancelToken) {
      manager.cancelToken.cancel(obj);
    }
  }

  Options _buildCacheOptions(APIManager manager, APIRequestOptions options) {
    APICacheOptions? cacheOptions = manager.apiCacheOptions;

    if (cacheOptions != null) {
      return buildCacheOptions(
        cacheOptions.shelfLife!,
        forceRefresh: cacheOptions.forceRefresh,
        options: options,
      );
    }
    return options;
  }

  /// 删除缓存
  @override
  Future<bool> deleteCacheForAPIManager(APIManager manager, [obj]) async {
    APICacheOptions? cacheOptions = manager.apiCacheOptions;
    bool? result = false;
    if (cacheOptions != null) {
      // 有缓存才删
      result = await _cacheManager?.deleteByPrimaryKey(
        manager.apiPathName,
        requestMethod: manager.apiMethod,
      );
    }
    return result ?? false;
  }

  @override
  deleteAllCache(APIManager manager, [obj]) {
    _cacheManager?.clearAll();
  }

  String cachePrimaryKeyForAPI(APIManager manager, APIRequestOptions options) {
    return '${options.method!}+${options.baseUrl}${manager.apiPathName}';
  }

  String cacheSubKeyForAPI(APIManager manager, APIRequestOptions options) {
    return options.queryParams?.toString() ?? options.data?.toString() ?? "";
  }

  /// 检测网络状态
  @override
  Future<APIConnectivityStatus> checkConnectivityStatus() async {
    return _conversionConnectivityResult(await (Connectivity().checkConnectivity()));
  }

  /// 监听网络状态变化
  @override
  StreamSubscription onConnectivityStatusChanged(Function(APIConnectivityStatus status) listen) {
    return Connectivity().onConnectivityChanged.listen((event) {
      listen(_conversionConnectivityResult(event));
    });
  }

  static APIConnectivityStatus _conversionConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return APIConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        return APIConnectivityStatus.mobile;
      default:
    }
    return APIConnectivityStatus.none;
  }

}

class APICacheOptions {
  /// 保质期
  Duration? shelfLife;
  /// 强制刷新数据
  bool? forceRefresh;

  APICacheOptions({
    this.shelfLife = const Duration(minutes: 5),
    this.forceRefresh,
  });

  APICacheOptions.for15m({
    this.shelfLife = const Duration(minutes: 15),
    this.forceRefresh,
  });

  APICacheOptions.for30m({
    this.shelfLife = const Duration(minutes: 30),
    this.forceRefresh,
  });

  APICacheOptions.for60m({
    this.shelfLife = const Duration(minutes: 60),
    this.forceRefresh,
  });

  APICacheOptions.for60s({
    this.shelfLife = const Duration(seconds: 60),
    this.forceRefresh,
  });

  APICacheOptions.for30s({
    this.shelfLife = const Duration(seconds: 30),
    this.forceRefresh,
  });

  APICacheOptions.for15s({
    this.shelfLife = const Duration(seconds: 15),
    this.forceRefresh,
  });

  APICacheOptions.for10s({
    this.shelfLife = const Duration(seconds: 10),
    this.forceRefresh,
  });

  APICacheOptions.for5s({
    this.shelfLife = const Duration(seconds: 5),
    this.forceRefresh,
  });

  APICacheOptions.for3s({
    this.shelfLife = const Duration(seconds: 3),
    this.forceRefresh,
  });

}
