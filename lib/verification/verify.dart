//  verify.dart
//  see_app
//
//  Created by JohnnyB0Y on 2020/5/13.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//

/// 可验证接口协议
abstract class Verifiable {

  /// 有错误返回 VerifyError对象，无错误返回 null
  VerifyError? verifyData(dynamic data);
}

/// 验证错误
class VerifyError {

  /// 错误信息
  String? msg;

  /// 错误代码
  int? code;

  /// 打包的错误信息
  Map? userInfo;

  /// 由调用方传入的对象，起对象传递作用
  Object? context;

  VerifyError({this.msg, this.code, this.userInfo, this.context});

}

/// 验证结果
class VerifyResult {
  final bool hasError;
  String? msg;
  int? code;
  final List<VerifyError>? errors;

  VerifyResult({this.hasError=false, this.msg, this.code, this.errors});

  factory VerifyResult.hasError([String? msg, int? code]) {
    return VerifyResult(hasError: true, msg: msg, code: code);
  }
}


// ------------------------------ 几个简单验证器


/// 文字长度验证器
class TextLengthVerify implements Verifiable {

  final int maxLength;
  final int minLength;

  TextLengthVerify({this.maxLength=99999, this.minLength=0});

  factory TextLengthVerify.range(int min, int max) {
    return TextLengthVerify(minLength: min, maxLength: max);
  }

  @override
  VerifyError? verifyData(data) {
    // TODO: implement verifyData
    VerifyError error = VerifyError();

    if (data is String) {
      int length = data.length;
      error.msg = length > maxLength ? '字数不能超过$maxLength个' : null;
      error.msg = length < minLength ? '字数不能少于$minLength个' : null;

    }
    else if (data == null) {
      error.msg = minLength == 0 ? null : '字数不能少于$minLength个';
    }
    else {
      error.msg = '数据类型错误';

    }

    return error.msg == null ? null : error;
 }

}


/// id 数字校验
class IdNumberVerify implements Verifiable {

  @override
  VerifyError? verifyData(data) {
    // TODO: implement verifyData
    VerifyError error = VerifyError();

    if (data is num) {
      if (data < 1) {
        error.msg = '请输入有效ID';
      }
    }
    else {
      error.msg = '数据类型错误';

    }

    return error.msg == null ? null : error;
  }

}

/// 判空
class NotNullVerify implements Verifiable {
  @override
  VerifyError? verifyData(data) {
    // TODO: implement verifyData
    VerifyError error = VerifyError();

    if (data == null) {
      error.msg = '数据不能为空';
    }

    return error.msg == null ? null : error;
  }
}
