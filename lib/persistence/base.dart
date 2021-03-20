//  base.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//

import 'command.dart';
import 'statement.dart';
import 'core.dart';

enum FieldType {
  // 值是一个带符号的整数，根据值的大小存储在 1、2、3、4、6 或 8 字节中。
  integer,

  // 值是一个浮点值，存储为 8 字节的 IEEE 浮点数字。
  real,
  float,
  double,

  // 值是一个文本字符串，使用数据库编码（UTF-8、UTF-16BE 或 UTF-16LE）存储。
  text,

  // 值是一个 blob 数据，完全根据它的输入存储。
  blob,

  // 当文本数据被插入到亲缘性为NUMERIC的字段中时，
  // 如果转换操作不会导致数据信息丢失以及完全可逆，
  // 那么SQLite就会将该文本数据转换为INTEGER或REAL类型的数据，
  // 如果转换失败，SQLite仍会以TEXT方式存储该数据。
  numeric,
  boolean,
}

enum DBType {
  sqlite3,
  // mysql, // 未处理！！！！！！！！！
}

// ---------------------- 数据库命令调度接口 -----------------------
abstract class DBSchedulable {
  /// 当前使用中的数据库版本号，方便Table组装对应版本的 sql 执行命令
  String usingVersion();
  /// 当前数据库类型
  DBType databaseType();

  /// 执行sql命令
  /// @param cmd sql命令
  Future<dynamic> executeCommand(DBCommand cmd);

  /// 以事务方式执行sql命令
  /// @param cmds sql命令集合
  Future<dynamic> executeTransaction(List<DBCommand> cmds);

  /// 批量执行sql命令
  /// @param cmds sql命令集合
  Future<dynamic> executeBatch(List<DBCommand> cmds);

  /// 解包原始数据 => 数组数据
  /// @param result 查询结果原始数据
  List<dynamic> unpackQuery(dynamic result);
}

String stringForFieldType(FieldType type) {
  switch (type) {
    case FieldType.integer: return 'INTEGER';
    case FieldType.real: return 'REAL';
    case FieldType.float: return 'FLOAT';
    case FieldType.double: return 'DOUBLE';
    case FieldType.text: return 'TEXT';
    case FieldType.blob: return 'BLOB';
    case FieldType.numeric: return 'NUMERIC';
    case FieldType.boolean: return 'BOOLEAN';
    default: return 'NONE';
  }
}

typedef DBFieldCheckValue = bool Function<T>(T value);

// ------------------------ SQL Field -------------------------------------
class DBField<T> {

  var _notNull = false; // 指定在该列上不允许 NULL 值。
  var _unique = false; // 防止在一个特定的列存在两个记录具有相同的值。
  var _primaryKey = false; // 唯一标识数据库表中的每个记录
  var _primaryKeyDesc = false; // 主键索引是否降序
  var _autoIncrement = false; // 字段自增
  String indexedName; // 索引名称
  var uniqueIndexed = false; // 唯一索引 ？
  T _value;
  var valueChange = false; // 记录值改变状态
  DBFieldCheckValue checkFunc;
  String name; // 字段名称
  FieldType fieldType; // 字段类型
  String addVersion; // 添加到数据表时的版本，做数据表升级和降级时用到
  String removeVersion; // 从数据表中移除时的版本，做数据表升级和降级时用到
  final T defaultValue;

  DBField(
    this.name, // 字段名称
    this.fieldType, // 字段类型
    this.addVersion, // 添加到数据表时的版本，做数据表升级和降级时用到
    [this.defaultValue] // 默认值
  );

  // 设置值
  set value(T v) {
    if (this.checkFunc != null && this.checkFunc(v) == false) { // 检查数据
      // console.log(`字段检测不通过！field: ${this.name} value: ${v}`);
    }
    else {
      this.valueChange = true;
      this._value = v;
    }
  }

  // 获取值
  T get value {
    return this._value;
  }

  /// 检测值是否合法
  /// @param func 检测值的闭包
  DBField addCheckFunc(DBFieldCheckValue func) {
    this.checkFunc = func;
    return this;
  }

  /// 在当前版本是否可用 ？
  /// @param version 版本号
  bool isAvailableForVersion(String version) {
    if (this.removeVersion == null) {
      return double.parse(version) >= double.parse(this.addVersion);
    }
    return double.parse(version) < double.parse(this.removeVersion);
  }

  /// 是否在当前版本新增 ？
  /// @param version 版本号
  bool isAddForVersion(String version) {
    return version == this.addVersion;
  }

  /// 是否在当前版本删除 ？
  /// @param version 版本号
  bool isRemoveForVersion(String version) {
    return version == this.removeVersion;
  }

  /// 移除或废弃此字段
  /// @param v 移除或废弃此字段的版本号
  DBField removeAtVersion(String v) {
    this.removeVersion = v;
    return this;
  }

  /// 设为不为空
  DBField notNull() {
    this._notNull = true;
    return this;
  }

  /// 设为唯一
  DBField unique() {
    this._unique = true;
    return this;
  }

  /// 设为主键（主键会创建索引，默认是升序，可以通过desc 设为降序）
  /// @param desc 是否降序
  DBField primaryKey([bool desc]) {
    this._primaryKey = true;
    this._primaryKeyDesc = desc;
    return this;
  }

  /// 设为自增
  DBField autoIncrement() {
    this._autoIncrement = true;
    return this;
  }

  /// 设为索引
  /// @param indexedName 索引名称，默认是字段名
  DBField indexed({String indexedName, bool unique}) {
    this.indexedName = indexedName;
    this.uniqueIndexed = unique;
    return this;
  }

  /// 生成sql语句对象
  DBStatement statement(DBTable table) {
    var statement = DBStatement(table, sql: this.name);
    statement.appendSql(stringForFieldType(this.fieldType));
    if (this._primaryKey) {
      statement.appendSql('PRIMARY KEY');
      statement.appendSql((this._primaryKeyDesc ? 'DESC' : 'ASC'));
    }
    if (this._autoIncrement) {
      statement.appendSql('AUTOINCREMENT');
    }
    if (this._notNull) {
      statement.appendSql('NOT NULL');
    }
    if (this._unique) {
      statement.appendSql('UNIQUE');
    }
    if (this.defaultValue != null) {
      statement.appendSql('DEFAULT ${this.defaultValue}');
    }
    return statement;
  }
}
