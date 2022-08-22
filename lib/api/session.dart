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
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class APIDefaultSessionManager implements APISessionManager {

  final MemCacheStore memCacheStore = MemCacheStore();

  @override
  Future<Response> callAPIForAPIManager(APIManager manager, [obj]) async {

    APIRequestOptions options = manager.requestOptionsForAPIManager(manager);

    // 缓存配置
    final dio = Dio();
    var cacheOpt = _buildCacheOptions(manager, options);
    if (cacheOpt != null) {
      dio.interceptors.add(DioCacheInterceptor(options: cacheOpt));
    }

    // 取消请求的token
    manager.cancelToken ??= CancelToken();

    // 发起请求
    dio.options.baseUrl = options.baseUrl;
    Response response = await dio.request(
      manager.apiPathName,
      queryParameters: options.queryParams,
      data: options.data,
      options: options,
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

  CacheOptions? _buildCacheOptions(APIManager manager, APIRequestOptions options) {
    APICacheOptions? cacheOptions = manager.apiCacheOptions;

    if (cacheOptions != null) {
      // return buildCacheOptions(
      //   cacheOptions.shelfLife!,
      //   forceRefresh: cacheOptions.forceRefresh,
      //   options: options,
      // );
      return CacheOptions(
        // A default store is required for interceptor.
        store: memCacheStore,

        // All subsequent fields are optional.

        // Default.
        policy: cacheOptions.forceRefresh ? CachePolicy.refresh : CachePolicy.request,
        // Returns a cached response on error but for statuses 401 & 403.
        // Also allows to return a cached response on network errors (e.g. offline usage).
        // Defaults to [null].
        hitCacheOnErrorExcept: [401, 403],
        // Overrides any HTTP directive to delete entry past this duration.
        // Useful only when origin server has no cache config or custom behaviour is desired.
        // Defaults to [null].
        maxStale: cacheOptions.shelfLife,
        // Default. Allows 3 cache sets and ease cleanup.
        priority: CachePriority.normal,
        // Default. Body and headers encryption with your own algorithm.
        cipher: null,
        // Default. Key builder to retrieve requests.
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        // Default. Allows to cache POST requests.
        // Overriding [keyBuilder] is strongly recommended when [true].
        allowPostMethod: false,
      );
    }
    return null;
  }

  /// 删除缓存
  @override
  Future<bool> deleteCacheForAPIManager(APIManager manager, [obj]) async {
    APICacheOptions? cacheOptions = manager.apiCacheOptions;
    if (cacheOptions != null && manager.response?.requestOptions != null) {
      RequestOptions options = manager.response!.requestOptions!;
      await memCacheStore.delete(CacheOptions.defaultCacheKeyBuilder(options));
      return true;
    }
    return false;
  }

  @override
  deleteAllCache(APIManager manager, [obj]) {
    memCacheStore.clean();
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
  final Duration shelfLife;
  /// 强制刷新数据
  final bool forceRefresh;

  APICacheOptions(this.shelfLife, this.forceRefresh);

  factory APICacheOptions.for15m() => APICacheOptions.forMinutes(15);
  factory APICacheOptions.for30m() => APICacheOptions.forMinutes(30);
  factory APICacheOptions.for60m() => APICacheOptions.forMinutes(60);
  factory APICacheOptions.for60s() => APICacheOptions.forSeconds(60);
  factory APICacheOptions.for30s() => APICacheOptions.forSeconds(30);
  factory APICacheOptions.for15s() => APICacheOptions.forSeconds(15);
  factory APICacheOptions.for10s() => APICacheOptions.forSeconds(10);
  factory APICacheOptions.for5s() => APICacheOptions.forSeconds(5);
  factory APICacheOptions.for3s() => APICacheOptions.forSeconds(3);

  factory APICacheOptions.forSeconds(int seconds) => APICacheOptions(Duration(seconds: seconds), false);
  factory APICacheOptions.forMinutes(int minutes) => APICacheOptions(Duration(minutes: minutes), false);
}
