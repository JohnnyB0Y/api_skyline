//  core.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

import 'package:flutter/foundation.dart';
import 'statement.dart';
import 'command.dart';
import 'base.dart';

abstract class DBService {

  /// 创建或打开数据库（已创建就直接打开，没创建就先创建再打开)
  Future<DBSchedulable> createOrOpenDB();
  /// 关闭数据库
  Future<dynamic>  closeDB();
  /// 删除数据库
  Future<dynamic> deleteDB();

  /// 数据库变迁版本号记录 📝
  List<String> get migrationVersionList;
  /// 数据库名称
  String get databaseName;
}

typedef DBFieldConditionFunc = bool Function(DBField field);

abstract class DBTable {
  /// SQL 执行者
  final DBSchedulable scheduler;
  /// 数据库标识（用来对同一个表结构做区分创建，在返回tableName的时候用上）
  final String? flag;
  /// 添加进数据库的当前版本号，（方便一张表以另一个表名添加进数据库时，补齐前面的升级步骤）
  /// null 的时候，表示不需要补齐前面的升级步骤
  final String? addToDBVersion;

  DBTable(this.scheduler, {this.flag, this.addToDBVersion});

  /// 数据表名称
  String get tableName;
  /// 使用中的主键，例如用于默认查询、更新或删除等
  DBField get usingPrimaryKey;
  /// 需要用到的表字段数组（dart 不能遍历属性 Σ(⊙▽⊙"a ）
  List<DBField> get usingDBFields;

  /// 返回对应升级的版本操作
  /// @param version 对应升级版本
  /// @return sql 命令数组
  List<DBCommand>? tableUpgradeMigrationSteps(String version);

  /// 返回对应降级的版本操作
  /// @param version 对应降级版本
  /// @return sql 命令数组
  List<DBCommand>? tableDowngradeMigrationSteps(String version);

  /// 输出字典格式
  /// @param fields 待输出的字段数组
  /// @returns 字典格式数据
  Map<String, dynamic> toMap({List<DBField>? fields}) {
    fields = fields ?? usingDBFields;
    Map<String, dynamic> map = {};
    for (var field in fields) {
      map[field.name] = field.value;
    }
    return map;
  }

  // ----------------------------------- Generate sql command ---------------------------------------
  /// 创建数据表
  /// @param fields 表字段数组
  /// @returns sql命令
  DBCreate createCommand(List<DBField> fields) {
    return DBCreate(this, fields);
  }

  /// 创建索引
  /// @param field 字段
  /// @returns sql命令
  DBCommand indexedCommand(DBField field) {
    return DBIndexed(this).createForField(field);
  }

  /// 插入一行数据
  /// @param fields 表字段数组
  /// @returns sql命令
  DBInsert insertCommand({List<DBField>? fields}) {
    return DBInsert(this, fields ?? dequeueAvailableFieldsForVersion());
  }

  /// 更新一行数据
  /// @param fields 表字段数组
  /// @param where where 语句
  /// @returns sql命令
  DBUpdate updateCommand({List<DBField>? fields, DBWhereStatement? where}) {
    return DBUpdate(this, fields ?? dequeueAvailableFieldsForVersion(), where ?? primaryKeyWhereStatement());
  }

  /// 删除一行数据
  /// @param where where 语句
  /// @returns sql命令
  DBDelete deleteCommand({DBWhereStatement? where}) {
    return DBDelete(this, where ?? primaryKeyWhereStatement());
  }

  /// 查询数据表
  /// @param page 页数
  /// @param size 每页数据条数
  /// @param orderByFields 指定排序的字段
  /// @param descending 是否按降序排序
  /// @returns sql命令
  DBQuery queryCommand({page = 1, size = 20, DBField? orderField, bool descending = false}) {
    return DBQuery(this).orderBy(orderField ?? usingPrimaryKey, descending: descending).paged(page, size);
  }

  // ----------------------------------- Execute sql command ---------------------------------------
  /// 执行插入命令
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeInsert({DBCommand? cmd}) async {
    return scheduler.executeCommand(cmd ?? insertCommand());
  }

  /// 执行删除命令
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeDelete({DBCommand? cmd}) async {
    return scheduler.executeCommand(cmd ?? deleteCommand());
  }

  /// 执行更新操作
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeUpdate({DBCommand? cmd}) async {
    return scheduler.executeCommand(cmd ?? updateCommand());
  }

  /// 执行查询操作
  /// @param cmd sql 命令
  /// @returns 执行结果（这里用到了 scheduler 的 unpackQuery 方法解包查询结果）
  Future<List> executeQuery({DBCommand? cmd}) async {
    var result = await scheduler.executeCommand(cmd ?? queryCommand());
    return scheduler.unpackQuery(result);
  }

  /// 取出该版本号将要添加的字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueWillAddFieldsForVersion(String version) {
    return dequeueFieldsForCondition( (field) => field.isAddForVersion(version) );
  }

  /// 取出该版本号将要移除的字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueWillRemoveFieldsForVersion(String version) {
    return dequeueFieldsForCondition( (field) => field.isRemoveForVersion(version) );
  }

  /// 取出该版本号可用的所有字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueAvailableFieldsForVersion({String? version}) {
    return dequeueFieldsForCondition((field) {
      return field.isAvailableForVersion(version ?? scheduler.usingVersion());
    });
  }

  List<DBField> dequeueFieldsForCondition(DBFieldConditionFunc condition) {
    return usingDBFields.where((field) => condition(field)).toList();
  }

  /// 拼装主键的where sql语句
  /// @param pk 主键
  /// @returns 主键的sql语句
  DBWhereStatement primaryKeyWhereStatement({DBField? pk}) {
    pk = pk ?? usingPrimaryKey;
    return DBWhereStatement(this).field(pk).equalTo("${pk.value}");
  }
}

typedef WhenInsertDB = Future<int?> Function();
typedef WhenUpdateDB = Future<int?> Function();
typedef WhenDeleteDB = Future<int?> Function();
typedef WhenQueryDB = Future<Map?> Function();

/// 方便DBTable的派生类 with mixin，减少冗余代码。
abstract class DBTableSafetyCURD implements DBTable {

  /// 插入表
  Future<int?> safeInsert({DBInsert? cmd}) async {
    try {
      return await executeInsert(cmd: cmd); // 返回id
    } catch (err) {
      debugPrint('$err');
      return null;
    }
  }

  /// 更新表
  Future<int?> safeUpdate({DBUpdate? cmd}) async {
    try {
      return await executeUpdate(cmd: cmd); // 返回id
    } catch (err) {
      debugPrint('$err');
      return null;
    }
  }

  /// 删除表
  Future<int?> safeDelete({DBDelete? cmd}) async {
    try {
      return await executeDelete(cmd: cmd); // 返回id
    } catch (err) {
      debugPrint('$err');
      return null;
    }
  }

  /// 查询表
  Future<List<Map>> safeQuery({DBQuery? cmd}) async {
    try {
      return await executeQuery(cmd: cmd) as List<Map>; // 返回查询结果
    } catch (err) {
      debugPrint('$err');
      return [];
    }
  }

  /// 查询表,返回一个数据
  Future<Map?> safeQueryOne({DBQuery? cmd}) async {
    try {
      var items = await executeQuery(cmd: cmd); // 返回查询结果
      return items.isEmpty ? null : items.first;
    } catch (err) {
      debugPrint('$err');
      return null;
    }
  }

  /// 查询表,如果没有就插入表，再返回数据结果;
  /// whenQuery 当需要查询时会调用;
  /// whenInsert 当需要插入时会调用;
  /// 如果查不到并且插入失败，会返回null；
  Future<Map?> safeQueryOrInsertOne({required WhenQueryDB whenQuery, required WhenInsertDB whenInsert}) async {
    var r = await whenQuery.call();
    if (r == null) {
      var id = await whenInsert.call();
      return id == null ? null : await whenQuery.call();
    }
    return null;
  }
}
