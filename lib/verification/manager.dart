//  manager.dart
//  see_app
//
//  Created by JohnnyB0Y on 2020/5/13.
//  Copyright © 2020 JohnnyB0Y. All rights reserved.

//  

import 'verify.dart';

const String kVerifyManagerDefaultVerifying = 'kVerifyManagerDefaultVerifying';

class VerifyManager {
  final Map<String, List<Verifying>> _executeMap = {};
  
  VerifyManager({Map<String, List<Verifying>>? executeMap}) {
    if (executeMap is Map) {
      _executeMap.addAll(executeMap!);
    }
  }

  /// 默认的验证单个数据集
  VerifyManager.defaultVerifyingList(List<Verifying> verifyingList) {
    addVerifyingListForKey(kVerifyManagerDefaultVerifying, verifyingList);
  }

  /// 执行默认的单个数据集验证
  VerifyResult executeDefaultVerifyingList() {
    return executeVerifyingListForKey(kVerifyManagerDefaultVerifying);
  }

  /// 添加待执行的验证数据集, 同一个Key会覆盖旧的
  addVerifyingListForKey(String key, List<Verifying> verifyingList) {
    _executeMap[key] = verifyingList;
  }

  /// 执行待验证的数据集
  VerifyResult executeVerifyingListForKey(String key) {
    List<Verifying>? verifyingList = _executeMap[key];
    List<VerifyError> errors = [];
    bool hasError = false;

    // 开始验证
    verifyingList?.forEach((verifying) {

      VerifyError? error = verifying.execute();
      if (error != null) {
        
        if (hasError == false) {
          // 发现第一个错误
          hasError = true;
        }
        // 添加错误到集合
        errors.add(error);
      }

    });
    
    return VerifyResult(hasError: hasError, errors: errors);
  }

  /// 执行所有验证
  List<VerifyResult> executeAllVerifyingList() {
    
    List<VerifyResult> results = [];
    
    for (var key in _executeMap.keys) {
      VerifyResult result = executeVerifyingListForKey(key);
      results.add(result);
    }
    
    return results;
  }

}


/// 验证器调度者
class Verifying {

  /// 验证器
  final Verifiable verifier;

  /// 数据
  final Object data;

  /// 错误提示信息
  String? msg;

  /// 你想传递的对象（由VerifyError对象持有传递）
  Object? context;


  /// 验证数据，传入验证器、数据
  Verifying.data(this.verifier, this.data);

  /// 验证数据，直传入验证器、数据、错误提示信息
  Verifying.dataWithMsg(this.verifier, this.data, this.msg);

  /// 验证数据，传入验证器、数据、你想传递的对象
  Verifying.dataWithContext(this.verifier, this.data, this.context);

  /// 验证数据，传入验证器、数据、错误提示信息、你想传递的对象
  Verifying.dataWithMsgWithContext(this.verifier, this.data, this.msg, this.context);

  /// 执行 验证器
  VerifyError? execute() {

    VerifyError? error = verifier.verifyData(data);
    if (error != null) {
      error.context = context;
      error.msg = msg ?? error.msg;
    }

    return error;
  }
}
