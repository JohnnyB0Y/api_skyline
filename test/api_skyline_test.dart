import 'package:flutter_test/flutter_test.dart';
import 'package:api_skyline/api_skyline.dart';
import 'dart:io';

void main() {
  test('adds one to input values', () {
    // final calculator = Calculator();
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });

  // test case ...
  // 注册API service
  AppAPIService().registerForDefault();

}

class AppAPIService extends APIService implements NoticeObservable {
  AppAPIService() {
    // 监听or初始化
    // NoticeCenter.defaultCenter().addObserver(this, AccountNoticeName.loginSuccess);
    // NoticeCenter.defaultCenter().addObserver(this, AccountNoticeName.logoutSuccess);
    // this.environment = APIEnvironment.release;
  }


  @override
  get baseURL {
    if (this.isDebugMode) {
      if (this.environment == APIEnvironment.develop) {
        if (Platform.isAndroid) {
          return 'http://192.168.3.7:5000/';
        }
        return 'http://localhost:5000/';
      }
      else if (this.environment == APIEnvironment.releaseCandidate) {
        return 'https://your—domain';
      }
      else {
        return 'https://your—domain';
      }
    }
    return 'https://your—domain';
  }

  // 返回直接供APIManager使用的数据，JSON格式化后的数据
  @override
  Object? rawDataForAPIManager(APIManager manager) {
    // TODO: implement rawDataForAPIManager
    Object? data = manager.response?.bodyData;
    if (data is Map) {
      return data['data'];
    }
    else if (data is List) {
      return data;
    }

    return null;
  }

  @override
  VerifyResult? verifyHTTPCode(APIManager manager, int code) {
    // TODO: implement verifyHTTPCode
    // ✅ 状态码处理
    if (code == 200) return null;
    if (code == 201) return null;
    if (code == 202) return null;
    if (code == 204) return null;

    // ❌ 状态码处理
    APICallbackStatus status;
    String? errorMsg;

    var errorData = manager.errorDataForAPIManager(manager);
    if (errorData is Map) {
      var msg = errorData['msg'];
      if (msg is String) {
        errorMsg = msg;
      }
      else if (msg is Map) {
        errorMsg = msg.toString();
      }
    }

    switch (code) {
      case 400:
        status = APICallbackStatus.badRequest;
        errorMsg ??= '请求无效';
        break;
      case 401:
        status = APICallbackStatus.unauthorized;
        errorMsg ??= '身份失效';
        break;
      case 403:
        status = APICallbackStatus.forbidden;
        errorMsg ??= '权限不够';
        break;
      case 404:
        status = APICallbackStatus.notFound;
        errorMsg ??= '未找到资源';
        break;
      case 409:
        status = APICallbackStatus.denied;
        errorMsg ??= '拒绝访问';
        break;
      default:
        status = APICallbackStatus.serverError;
        errorMsg = '网络出错';
        break;
    }

    manager.callbackStatus = status;
    return VerifyResult.hasError(errorMsg, manager.callbackStatus.index);
  }

  @override
  bool handleGlobalError(APIManager manager, VerifyResult? error, exception) {
    // TODO: implement handleGlobalError
    bool finished = false;
    // switch (manager.callbackStatus) {
    //   case APICallbackStatus.unauthorized:
    //     var accountManager = AccountManager.sharedInstance();
    //     accountManager.isLogged().then((value) {
    //       if (value) {
    //         // 登录的状态下token过期
    //         // - 先退出登录
    //         accountManager.logout().then((value) {
    //           String username = accountManager.currentAccount.apiToken;
    //           String password = '10086';
    //           configAuthorization(username, password);
    //           // 删掉旧的所有缓存
    //           sessionManager.deleteAllCache(manager);
    //         });
    //
    //         // - 跑去登录界面
    //         MineDialogView.pushLoginPageIfNeeded(manager);
    //       }
    //       else {
    //         // 游客状态下token过期，更新游客token
    //         accountManager.updateVisitorAccount((success) { });
    //       }
    //
    //     });
    //     break;
    //   default:
    //     break;
    // }

    // 未处理，让程序往下走
    return finished;
  }

  @override
  configPagedParams(APIPagedManager manager, Map<String, Object> params) {
    // TODO: implement configPagedParams
    params['per_page'] = manager.pageSize;
    params['page'] = manager.currentPage;
  }

  @override
  bool isTheLastPageForAPIManager(APIPagedManager manager) {
    // TODO: implement isLastPageForAPIManager
    if (manager.rawData is Map) {
      return manager.rawData['last'] ?? false;
    }
    return true;
  }

  @override
  observedNotice(Notice notice, NoticeCenter noticeCenter) {
    // TODO: implement observedNotice
    // AccountContext account = notice.context;
    // if (notice.name == AccountNoticeName.loginSuccess) {
    //   String username = account.apiToken;
    //   String password = '10086';
    //   configAuthorization(username, password);
    //
    //   // 删掉旧的所有缓存
    //   sessionManager.deleteAllCache(null);
    // }
    // else if (notice.name == AccountNoticeName.logoutSuccess) {
    //   String username = account.apiToken;
    //   String password = '10086';
    //   configAuthorization(username, password);
    //
    //   // 删掉旧的所有缓存
    //   sessionManager.deleteAllCache(null);
    // }
  }
}
