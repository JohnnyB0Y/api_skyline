//  demo_db_service.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 2021/5/17.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

import 'package:api_skyline/persistence/base.dart';
import 'package:api_skyline/persistence/core.dart';

class DemoDBService extends DBService {
  @override
  Future closeDB() {
    // TODO: implement closeDB
    throw UnimplementedError();
  }

  @override
  Future<DBSchedulable> createOrOpenDB() {
    // TODO: implement createOrOpenDB
    throw UnimplementedError();
  }

  @override
  // TODO: implement databaseName
  String get databaseName => "demo_db";

  @override
  Future deleteDB() {
    // TODO: implement deleteDB
    throw UnimplementedError();
  }

  @override
  // TODO: implement migrationVersionList
  List<String> get migrationVersionList => ["1"];

}
