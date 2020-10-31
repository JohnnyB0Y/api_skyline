//  manager.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  对API请求的生命周期的管理

import 'package:dio/dio.dart';
import 'request.dart';
import 'response.dart';
import 'config.dart';
import 'service.dart';
import 'define.dart';
import 'session.dart';
import '../react/model.dart';
import '../verification/verify.dart';


abstract class APIManager extends Object implements APIAssembly {

  // API 回调代理
  APICallDelegate callDelegate;
  // 验证器
  APIVerifier verifier;
  // 生命周期拦截器
  APIInterceptor interceptor;

  VerifyResult errorResult;

  Map<String, Object> _clientParams;
  APIService _service;
  APIResponse _response;
  Object _rawData;
  bool _isLoading = false;
  dynamic cancelToken;

  APICallbackStatus callbackStatus = APICallbackStatus.none;

  Map<String, Object> get clientParams => _clientParams ?? Map();
  dynamic get rawData => _rawData;
  APIResponse get response => _response;
  bool get isLoading => _isLoading;


  // TODO ---------------------------- call api -----------------------------------
  /// 通过传入参数调用API
  loadDataWithParams(Map<String, Object> params) async {
    if (_isLoading) {
      return;
    }

    // 启动服务
    _service = APIConfig.dequeueAPIServiceForKey(apiServiceKey);

    if (_service == null) {
      callbackStatus = APICallbackStatus.none;
      _apiCallbackFailure();
      return;
    }
    
    // 参数校验
    _clientParams = params ?? Map();
    _clientParams = reformParams(_clientParams);
    if (_verifyCallParams(_clientParams) == false) {
      callbackStatus = APICallbackStatus.paramError;
      _apiCallbackFailure();
      // 参数错误，终止请求
      return;
    }


    try {
      /// 网络请求阶段 ----------------------
      if (_beforeCallingAPI(this) == false) {
        return;
      }
      _isLoading = true; // 请求中

      Response response = await _service.sessionManager.callAPIForAPIManager(this);

      _isLoading = false; // 请求结束
      if (_afterCallingAPI(this) == false) {
        return;
      }

      /// 数据处理阶段 -----------------------
      _response = responseForAPIManager(this, response);

      // 判断 http code
      if (_verifyHTTPCode(_response.httpCode) == true) {
        // http code pass
        _rawData = rawDataForAPIManager(this);
        // 校验数据
        if (_verifyCallbackData(_rawData) == false) {
          // 校验出错
          callbackStatus = APICallbackStatus.dataError;
          if (_handleGlobalError(null) == false) {
            _apiCallbackFailure();
          }

        }
        else {
          callbackStatus = APICallbackStatus.success;
          _apiCallbackSuccess();
        }
      }
      else {
        // http code no pass
        if (_handleGlobalError(null) == false) {
          _apiCallbackFailure();
        }
      }

    }
    on DioError catch (e) {
      _isLoading = false; // 请求结束
      callbackStatus = APICallbackStatus.exceptionError;
      var errorMsg = '程序异常';

      if (e is DioError) {
        switch (e.type) {
          case DioErrorType.CONNECT_TIMEOUT:
            callbackStatus = APICallbackStatus.timeout;
            errorMsg = '网络连接超时';
            break;
          case DioErrorType.SEND_TIMEOUT:
            callbackStatus = APICallbackStatus.timeout;
            errorMsg = '网络发送超时';
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
            callbackStatus = APICallbackStatus.timeout;
            errorMsg = '网络接收超时';
            break;
          case DioErrorType.CANCEL:
            callbackStatus = APICallbackStatus.cancel;
            errorMsg = '取消网络请求';
            break;
          default:
            // 其他错误，例如状态码错误
            int httpCode = e.response?.statusCode;
            if (httpCode != null) {
              _verifyHTTPCode(httpCode);
            }
        }
      }

      errorResult = VerifyResult.hasError(errorMsg, callbackStatus.index);
      if (_handleGlobalError(e) == false) {
        _apiCallbackFailure();
      }
    }
  }

  /// 调用API加载数据
  loadData() async {
    loadDataWithParams(callDelegate?.apiCallParams?.call(this));
  }

  /// 取消请求
  cancelAPIRequest([dynamic reason]) {
    _service?.sessionManager?.cancelAPIForAPIManager(this, reason);
  }

  /// 清除API缓存
  deleteAPICache() {
    _service = APIConfig.dequeueAPIServiceForKey(apiServiceKey);
    _service?.sessionManager?.deleteCacheForAPIManager(this);
  }

  // 获取整理后的数据
  ReactModel fetchReactModel(APIReformerDelegate reformer, [Object obj]) {
    try {
      return reformer?.reformDataToReactModel(this, this.rawData, obj);
    }
    catch (e) {
      print('APIReformerDelegate reformDataToReactModel $e');
      callbackStatus = APICallbackStatus.reformerDataError;
      _apiCallbackFailure();
    }
    return null;
  }

  // 获取整理后的数据
  List<ReactModel> fetchReactModels(APIReformerDelegate reformer, [Object obj]) {
    try {
      return reformer?.reformDataToReactModels(this, this.rawData, obj);
    }
    catch (e) {
      print('APIReformerDelegate reformDataToReactModels $e');
      callbackStatus = APICallbackStatus.reformerDataError;
      _apiCallbackFailure();
    }
    return null;
  }


  bool _beforeCallingAPI(APIManager manager) {
    return (interceptor == null)
        ? beforeCallingAPI(this)
        : interceptor.beforeCallingAPI(this);
  }


  bool _afterCallingAPI(APIManager manager) {
    return (interceptor == null)
        ? afterCallingAPI(this)
        : interceptor.afterCallingAPI(this);
  }


  bool _verifyCallbackData(Object data) {
    if (verifier == null) {
      errorResult = verifyCallbackData(data);
    }
    else {
      errorResult = verifier.verifyCallbackData(this, data);
    }
    return (errorResult == null) ? true : (! errorResult.hasError);
  }


  bool _verifyCallParams(Map<String, Object> params) {
    if (verifier == null) {
      errorResult = verifyCallParams(params);
    }
    else {
      errorResult = verifier.verifyCallParams(this, params);
    }
    return (errorResult == null) ? true : (! errorResult.hasError);
  }


  bool _verifyHTTPCode(int code) {
    errorResult = verifyHTTPCode(this, code);
    return (errorResult == null) ? true : (! errorResult.hasError);
  }


  bool _handleGlobalError(exception) {
    return handleGlobalError(this, errorResult, exception);
  }


  _apiCallbackFailure() {
    bool callback = (interceptor == null)
        ? beforePerformApiCallbackFailure(this)
        : interceptor.beforePerformApiCallbackFailure(this);

    if (callback) {
      callDelegate?.apiCallbackFailure(this);
    }

    afterPerformApiCallbackFailure(this);
  }


  _apiCallbackSuccess() {
    bool callback = (interceptor == null)
        ? beforePerformApiCallbackSuccess(this)
        : interceptor.beforePerformApiCallbackSuccess(this);

    if (callback) {
      callDelegate?.apiCallbackSuccess(this);
    }

    afterPerformApiCallbackSuccess(this);
  }

  //
  // API请求必须参数 override
  //

  // 取出API 服务器的 key
  String get apiServiceKey {
    return kDefaultAPIServiceKey;
  }

  // API调用方式
  APICallType get apiCallType;

  String get apiMethod {
    switch (this.apiCallType) {
      case APICallType.get:
        return "GET";
        break;
      case APICallType.post:
        return "POST";
        break;
      case APICallType.put:
        return "PUT";
        break;
      case APICallType.delete:
        return "DELETE";
        break;
      case APICallType.head:
        return "HEAD";
        break;
      case APICallType.patch:
        return "PATCH";
        break;
    }
    return 'GET';
  }

  // API 方法名
  String get apiPathName;

  //
  // API缓存策略 override
  //
  APICacheOptions get apiCacheOptions => null;

  //
  // 切片方法 override
  //

  /// 验证回调数据是否合规
  VerifyResult verifyCallbackData(Object data) {
    return null;
  }

  /// 验证请求参数是否合规
  VerifyResult verifyCallParams(Map<String, Object> params) {
    return null;
  }

  /// API起飞前, 返回值为false即打断请求
  bool beforeCallingAPI(APIManager manager) {
    return true;
  }

  /// API落地后, 返回值为false即打断回调
  bool afterCallingAPI(APIManager manager) {
    return true;
  }

  /// API失败回调执行前，返回值为false即打断回调
  bool beforePerformApiCallbackFailure(APIManager manager) {
    return true;
  }

  /// API失败回调执行后
  afterPerformApiCallbackFailure(APIManager manager) {}

  /// API成功回调执行前，返回值为false即打断回调
  bool beforePerformApiCallbackSuccess(APIManager manager) {
    return true;
  }

  /// API成功回调执行后
  afterPerformApiCallbackSuccess(APIManager manager) {}
  
  /// 整理参数，返回整理后的参数
  Map<String, Object> reformParams(Map<String, Object> params) {
    return params;
  }

  /// 处理HTTP状态码
  VerifyResult verifyHTTPCode(APIManager manager, int code) {
    return _service?.verifyHTTPCode(manager, code);
  }

  /// 全局错误，处理成功 返回 true 就不调用callback函数了，处理失败返回 false 继续往下走。
  bool handleGlobalError(APIManager manager, VerifyResult error, exception) {
    return _service?.handleGlobalError(manager, error, exception);
  }

  // -------------- API 组装相关
  @override
  APIResponse responseForAPIManager(APIManager manager, Response response) {
    // TODO: implement responseForAPIManager
    return _service?.responseForAPIManager(manager, response);
  }

  /// 在这里可以override 修改请求参数配置，例如超时时间、请求头信息等
  @override
  APIRequestOptions requestOptionsForAPIManager(APIManager manager) {
    return _service?.requestOptionsForAPIManager(manager);
  }

  @override
  Object rawDataForAPIManager(APIManager manager) {
    // TODO: implement rawDataForAPIManager
    return _service?.rawDataForAPIManager(manager);
  }

  @override
  Object errorDataForAPIManager(APIManager manager) {
    // TODO: implement errorDataForAPIManager
    return _service?.errorDataForAPIManager(manager);
  }

  @override
  String finalURL(String baseURL, String apiMethod, [Map param]) {
    // TODO: implement finalURL
    return _service?.finalURL(baseURL, apiMethod, param);
  }

  // 连接超时时间
  @override
  int connectTimeout() {
    return _service?.connectTimeout();
  }

  // 接收数据超时时间
  @override
  int receiveTimeout() {
    return _service?.receiveTimeout();
  }

  // 发送数据超时时间
  @override
  int sendTimeout() {
    return _service?.sendTimeout();
  }

}

// api 分页管理者
abstract class APIPagedManager extends APIManager {
  int pageSize = 15;
  int _currentPage = 1;
  bool _isFirstPage = true;
  bool _isLastPage = false;

  int get currentPage => _currentPage;
  bool get isFirstPage => _isFirstPage;
  bool get isLastPage => _isLastPage;

  @override
  loadData() {
    // TODO: implement loadData
    loadDataWithParams(callDelegate?.apiCallParams?.call(this));
  }

  loadNextData() {
    loadNextDataWithParams(callDelegate?.apiCallParams?.call(this));
  }

  @override
  loadDataWithParams(Map<String, Object> params) {
    // TODO: implement loadData
    _isFirstPage = true;
    _currentPage = 1;

    super.loadDataWithParams(params);
  }

  loadNextDataWithParams(Map<String, Object> params) {
    if (_isLoading) {
      return;
    }

    if (_isLastPage) {
      // 最后一页
      callbackStatus = APICallbackStatus.lastPageError;
      _apiCallbackFailure();
      return;
    }

    super.loadDataWithParams(params);
  }

  @override
  Map<String, Object> reformParams(Map<String, Object> params) {
    configPagedParams(params);
    return super.reformParams(params);
  }

  @override
  bool beforePerformApiCallbackSuccess(APIManager manager) {

    _isLastPage = isTheLastPageForAPIManager(manager);
    _isFirstPage = _currentPage == 1;
    if (_isLastPage == false) {
      _currentPage++;
    }

    return super.beforePerformApiCallbackSuccess(manager);
  }

  // 配置分页参数
  configPagedParams(Map<String, Object> params) {
    _service?.configPagedParams(this, params);
  }

  // 验证是否最后一页
  bool isTheLastPageForAPIManager(APIManager manager) {
    return _service?.isTheLastPageForAPIManager(manager);
  }

}
