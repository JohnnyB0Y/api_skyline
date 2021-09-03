//  statement.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

// ------------------------ SQL Statement ------------------------------
import 'core.dart';
import 'base.dart';

class DBStatement {
  final DBTable table;
  late String sql;
  late List<dynamic> params;
  DBStatement(this.table, {String? sql, List<dynamic>? params}) {
    this.sql = sql ?? "";
    this.params = params ?? [];
  }

  /// 在sql语句后拼接字符串
  /// @param str 拼接的字符串
  /// @param betweenStr 拼接之间的间隔字符串，默认空格字符串 ' '
  DBStatement appendSql(String str, [String betweenStr=" "]) {
    this.sql += betweenStr + str;
    return this;
  }

  /// 拼接参数
  /// @param param 参数
  DBStatement appendParam(dynamic param) {
    this.params.add(param);
    return this;
  }

  /// 合并参数
  /// @param params 待合并的参数数组
  DBStatement mergeParams(List params) {
    params.forEach((param) {
      this.params.add(param);
    });
    return this;
  }
}

// ------------------------ SQL IndexedStatement ----------------------------
class DBIndexedStatement extends DBStatement {
  DBIndexedStatement(DBTable table) : super(table);
 // 指定操作使用的索引
  DBIndexedStatement indexedBy(String indexName) {
    this.sql = 'INDEXED BY ' + indexName;
    return this;
  }
  DBIndexedStatement notIndexed() {
    this.sql = 'NOT INDEXED';
    return this;
  }
}

// ------------------------ SQL OrderStatement ----------------------------
class DBOrderStatement extends DBStatement {

  bool isFirstField = true;

  DBOrderStatement(DBTable table) : super(table, sql: 'ORDER BY');

  /// 查询返回数据的排序条件。
  /// 降序排列 [4, 3, 2, 1]
  /// 升序排列 [1, 2, 3, 4]
  /// @param field 排序字段
  /// @param descending 是否降序排列（默认升序排列）
  DBOrderStatement orderByField(DBField field, bool descending) {
    this.isFirstField ? this.isFirstField = false : this.sql += ',';
    var order = descending ? 'DESC' : 'ASC';
    return this.orderByFieldSql('${field.name} $order');
  }

  DBOrderStatement orderByFieldSql(String fieldSql) {
    return this.appendSql(fieldSql) as DBOrderStatement;
  }

  /// 查询返回数据的排序条件。
  /// @param column 排序的列位（字段的列的位置）
  /// @param descending 是否降序排列（默认升序排列）
  DBOrderStatement orderByColumn(int column, bool descending) {
    this.isFirstField ? this.isFirstField = false : this.sql += ',';
    var order = descending ? 'DESC' : 'ASC';
    return this.appendSql('$column $order') as DBOrderStatement;
  }
}

// ------------------------ SQL GroupStatement ----------------------------
class DBGroupStatement extends DBStatement {

  bool isFirstField = true;

  DBGroupStatement(DBTable table) : super(table, sql: 'GROUP BY');

  /// 对相同的数据进行分组
  /// @param field 分组字段
  /// @param tableName 表名
  DBGroupStatement groupByField(DBField field, [String? tableName]) {
  this.isFirstField ? this.isFirstField = false : this.sql += ',';
    return this.groupByFieldSql(tableName == null ? field.name : '$tableName.${field.name}');
  }

  DBGroupStatement groupByFieldSql(String fieldSql) {
    return this.appendSql(fieldSql) as DBGroupStatement;
  }
}

// ------------------------ SQL WhereStatement --------------------------------
class DBWhereStatement extends DBStatement {

  DBWhereStatement(DBTable table) : super(table, sql: 'WHERE');

  /// 直接连接下一个字段条件
  /// @param f 字段
  DBWhereStatement field(DBField f) {
    return this.appendSql(f.name) as DBWhereStatement;
  }

  /// 用 AND 连接下一个字段条件
  /// @param f 字段
  DBWhereStatement andField(DBField f) {
    return this.appendSql('AND ${f.name}') as DBWhereStatement;
  }

  /// 用 OR 连接下一个字段条件
  /// @param f 字段
  DBWhereStatement orField(DBField f) {
    return this.appendSql('OR ${f.name}') as DBWhereStatement;
  }

  /// 条件：等于
  /// @param value 数值
  DBWhereStatement equalTo(String value) {
    return this.condition('=', value);
  }

  /// 条件：不等于
  /// @param value 数值
  DBWhereStatement notEqualTo(String value) {
    return this.condition('!=', value);
  }

  /// 条件：大于
  /// @param value 数值
  DBWhereStatement greaterThan(String value) {
    return this.condition('>', value);
  }

  /// 条件：大于等于
  /// @param value 数值
  DBWhereStatement greaterEqual(String value) {
    return this.condition('>=', value);
  }

  /// 条件：小于
  /// @param value 数值
  DBWhereStatement lessThan(dynamic value) {
    return this.condition('<', value);
  }

  /// 条件：小于等于
  /// @param value 数值
  DBWhereStatement lessEqual(dynamic value) {
    return this.condition('<=', value);
  }

  /// 条件：匹配通配符；https://www.runoob.com/sqlite/sqlite-like-clause.html
  /// @param value 匹配字符串（%）
  DBWhereStatement like(String value) {
    return this.condition('LIKE', value);
  }

  /// 条件：匹配通配符；https://www.runoob.com/sqlite/sqlite-glob-clause.html
  /// @param value 匹配字符串
  DBWhereStatement glob(String value) {
    return this.condition('GLOB', value);
  }

  /// 条件：在values里面
  /// @param values 数值数组
  DBWhereStatement inValues(List<dynamic> values) {
    var sql = '';
    for (int i = 0; i<values.length; i++) {
      this.params.add(values[i]);
      sql += (i == 0) ? '?' : ', ?';
    }
    return this.appendSql('IN ($sql)') as DBWhereStatement;
  }

  /// 条件：不在values里面
  /// @param values 数值数组
  DBWhereStatement notInValues(List<dynamic> values) {
    var sql = '';
    for (int i = 0; i<values.length; i++) {
      this.params.add(values[i]);
      sql += (i == 0) ? '?' : ', ?';
    }
    return this.appendSql('NOT IN ($sql)') as DBWhereStatement;
  }

  /// 条件：在 start 与 end 之间
  /// @param start 开始值
  /// @param end 结束值
  DBWhereStatement between(dynamic start,dynamic end) {
    this.params.add(start);
    this.params.add(end);
    return this.appendSql('BETWEEN ? AND ?') as DBWhereStatement;
  }

  /// 条件判断
  /// @param operators 操作类型的字符串
  /// @param value 条件值
  DBWhereStatement condition(String operators, dynamic value) {
    this.params.add(value);
    return this.appendSql('$operators ?') as DBWhereStatement;
  }
}
