//  core.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

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

  DBTable(this.scheduler, [this.flag]);

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
    fields = fields ?? this.usingDBFields;
    Map<String, dynamic> map = Map();
    fields.forEach((field) {
      map[field.name] = field.value;
    });
    return map;
  }

  // ----------------------------------- Generate sql command ---------------------------------------
  /// 创建数据表
  /// @param fields 表字段数组
  /// @returns sql命令
  DBCreate createCommand(List<DBField> fields) {
    return new DBCreate(this, fields);
  }

  /// 创建索引
  /// @param field 字段
  /// @returns sql命令
  DBCommand indexedCommand(DBField field) {
    return new DBIndexed(this).createForField(field);
  }

  /// 插入一行数据
  /// @param fields 表字段数组
  /// @returns sql命令
  DBInsert insertCommand({List<DBField>? fields}) {
    return new DBInsert(this, fields ?? this.dequeueAvailableFieldsForVersion());
  }

  /// 更新一行数据
  /// @param fields 表字段数组
  /// @param where where 语句
  /// @returns sql命令
  DBUpdate updateCommand({List<DBField>? fields, DBWhereStatement? where}) {
    return new DBUpdate(this, fields ?? this.dequeueAvailableFieldsForVersion(), where ?? this.primaryKeyWhereStatement());
  }

  /// 删除一行数据
  /// @param where where 语句
  /// @returns sql命令
  DBDelete deleteCommand({DBWhereStatement? where}) {
    return new DBDelete(this, where ?? this.primaryKeyWhereStatement());
  }

  /// 查询数据表
  /// @param page 页数
  /// @param size 每页数据条数
  /// @param orderByFields 指定排序的字段
  /// @param descending 是否按降序排序
  /// @returns sql命令
  DBQuery queryCommand({page = 1, size = 20, DBField? orderField, bool descending = false}) {
    return new DBQuery(this).orderBy(orderField ?? this.usingPrimaryKey, descending: descending).paged(page, size);
  }

  // ----------------------------------- Execute sql command ---------------------------------------
  /// 执行插入命令
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeInsert({DBCommand? cmd}) async {
    return this.scheduler.executeCommand(cmd ?? this.insertCommand());
  }

  /// 执行删除命令
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeDelete({DBCommand? cmd}) async {
    return this.scheduler.executeCommand(cmd ?? this.deleteCommand());
  }

  /// 执行更新操作
  /// @param cmd sql 命令
  /// @returns 执行结果
  Future<dynamic> executeUpdate({DBCommand? cmd}) async {
    return this.scheduler.executeCommand(cmd ?? this.updateCommand());
  }

  /// 执行查询操作
  /// @param cmd sql 命令
  /// @returns 执行结果（这里用到了 scheduler 的 unpackQuery 方法解包查询结果）
  Future<List> executeQuery({DBCommand? cmd}) async {
    var result = await this.scheduler.executeCommand(cmd ?? this.queryCommand());
    return this.scheduler.unpackQuery(result);
  }

  /// 取出该版本号将要添加的字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueWillAddFieldsForVersion(String version) {
    return this.dequeueFieldsForCondition( (field) => field.isAddForVersion(version) );
  }

  /// 取出该版本号将要移除的字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueWillRemoveFieldsForVersion(String version) {
    return this.dequeueFieldsForCondition( (field) => field.isRemoveForVersion(version) );
  }

  /// 取出该版本号可用的所有字段
  /// @param version 版本号
  /// @returns 字段数组
  List<DBField> dequeueAvailableFieldsForVersion({String? version}) {
    return this.dequeueFieldsForCondition((field) {
      return field.isAvailableForVersion(version ?? this.scheduler.usingVersion());
    });
  }

  List<DBField> dequeueFieldsForCondition(DBFieldConditionFunc condition) {
    return usingDBFields.where((field) => condition(field)).toList();
  }

  /// 拼装主键的where sql语句
  /// @param pk 主键
  /// @returns 主键的sql语句
  DBWhereStatement primaryKeyWhereStatement({DBField? pk}) {
    pk = pk ?? this.usingPrimaryKey;
    return DBWhereStatement(this).field(pk).equalTo("${pk.value}");
  }


}
