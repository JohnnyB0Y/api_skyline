//  request.dart
//
//
//  Created by JohnnyB0Y on 2020/5/10.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

import 'package:dio/dio.dart';

class APIRequestOptions extends Options {

  String baseUrl;
  Map<String, dynamic>? queryParams;
  dynamic data;
  int? connectTimeout;

  APIRequestOptions({
    required this.baseUrl,
    this.queryParams,
    this.data,
    this.connectTimeout,
    required String method,
    int? sendTimeout,
    int? receiveTimeout,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
  }) : super(
    method: method,
    sendTimeout: Duration(seconds: sendTimeout ?? 16),
    receiveTimeout: Duration(seconds: receiveTimeout ?? 16),
    extra: extra,
    headers: headers,
    responseType: responseType,
    contentType: contentType,
    validateStatus: validateStatus,
    receiveDataWhenStatusError: receiveDataWhenStatusError,
    followRedirects: followRedirects,
    maxRedirects: maxRedirects,
    requestEncoder: requestEncoder,
    responseDecoder: responseDecoder,
  );

}
