//  command.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

import 'statement.dart';
import 'core.dart';
import 'base.dart';

class DBCommand {
  final DBTable table;
  late String _sql;
  List<dynamic>? _params;

  DBCommand(this.table, {String sql="", List<dynamic>? params}) {
    _sql = sql;
    _params = params;
  }

  String get sql {
    return _sql;
  }

  List<dynamic> get params {
    _params ??= [];
    return _params!;
  }

}

// ------------------------ SQL Select --------------------------------
class DBSelect extends DBCommand {
  bool isFirstField = true;
  DBSelect(DBTable table) : super(table, sql: 'SELECT');

  /// 对结果去重
  DBSelect distinct() {
    _sql += ' DISTINCT';
    return this;
  }

  /// 需要取出的字段
  /// @param field 字段
  /// @param tableName 表名
  /// @param asField 字段别名（返回的数据表使用）
  DBSelect field(DBField field, {String? tableName, String? asField}) {
    isFirstField ? isFirstField = false : _sql += ',';
    _sql += tableName == null ? ' ${field.name}' : ' $tableName.${field.name}';
    _sql += asField == null ? '' : ' AS $asField';
    return this;
  }

  /// 需要取出的字段
  /// @param field 字段
  /// @param tableName 表名
  /// @param asField 字段别名（返回的数据表使用）
  DBSelect andField(DBField field, {String? fromTable, String? asField}) {
    return this.field(field, tableName: fromTable, asField: asField);
  }

  /// 查询取出所有字段
  DBSelect allField() {
    _sql += ' *';
    return this;
  }

  /// 计数
  DBSelect count(DBCountStatement count) {
    _sql += ' ${count.sql}';
    return this;
  }

  /// 左边的表（A表）
  /// @param tableA 表名
  DBSelect fromTable(String tableA) {
    _sql += ' FROM $tableA';
    return this;
  }

  /// 内连接查询，获得两表的交集，即共有的行。
  /// @param tableB 表名
  DBSelect innerJoin(String tableB) {
    _sql += ' INNER JOIN $tableB ON';
    return this;
  }

  /// 左外连接查询，获得A表所有的列，加上匹配到B表的列。
  /// @param tableB 表名
  DBSelect leftJoin(String tableB) {
    _sql += ' LEFT OUTER JOIN $tableB ON';
    return this;
  }

  /// 交叉连接查询，表A的每一行与表B的每一行进行组合。
  /// A[1, 2] B[a, b] => [(1, a), (1, b), (2, a), (2, b)]
  /// @param tableB 表名
  DBSelect crossJoin(String tableB) {
    _sql += ' CROSS JOIN $tableB';
    return this;
  }

  /// innerJoin 和 leftJoin 的条件判断
  /// @param tableA 表A
  /// @param field1 表A字段
  /// @param tableB 表B
  /// @param field2 表B字段
  /// @param operators 条件操作符（不用传）
  DBSelect onCondition(String tableA, DBField field1, String tableB, DBField field2, {String operators = '='}) {
    _sql += ' $tableA.${field1.name} $operators $tableB.$field2.name';
    return this;
  }

  /// 通过指定索引查询
  /// @param indexed 索引语句
  DBSelect indexed(DBIndexedStatement indexed) {
    _sql += ' ${indexed.sql}';
    return this;
  }

  /// 对结果进行筛选
  /// @param where where语句
  DBSelect where(DBWhereStatement where) {
    _sql += ' ${where.sql}';
    for (var param in where.params) {
      params.add(param);
    }
    return this;
  }

  /// 对相同的数据进行分组
  /// @param group 分组语句
  DBSelect group(DBGroupStatement group) {
    _sql += ' ${group.sql}';
    return this;
  }

  /// 查询返回数据的排序条件。
  /// @param fields 排序语句
  DBSelect order(DBOrderStatement order) {
    _sql += ' ${order.sql}';
    return this;
  }

  /// 查询返回的数量限制
  /// @param num 限制量
  DBSelect limit(int num) {
    _sql += ' LIMIT $num';
    return this;
  }

  /// 查询返回数据的偏移值
  /// @param num 偏移量
  DBSelect offset(int num) {
    _sql += ' OFFSET $num';
    return this;
  }
}

// ------------------------ SQL Query --------------------------------
class DBQuery extends DBCommand {

  late DBSelect selectCmd;
  final List<DBField>? fields;
  final DBCountStatement? count;
  final DBWhereStatement? where;
  final DBIndexedStatement? indexed;

  DBQuery(DBTable table, {this.fields, this.where, this.indexed, this.count}) : super(table) {
    selectCmd = DBSelect(this.table);
    if (fields == null) {
      if (count == null) { // 查询所有字段
        selectCmd.allField();
      } else { // 计数
        selectCmd.count(count!);
      }
    } else { // 查询指定字段
      for (int i = 0; i<fields!.length; i++) {
        selectCmd.field(fields![i]);
      }
      if (count != null) { // 计数
        selectCmd.count(count!);
      }
    }

    selectCmd.fromTable(table.tableName);

    if (indexed != null) {
      selectCmd.indexed(indexed!);
    }
    if (where != null) {
      selectCmd.where(where!);
      params.addAll(where!.params);
    }
  }

  /// 查询返回数据的排序条件
  /// @param field 排序字段
  /// @param descending 是否降序排列
  DBQuery orderBy(DBField field, {bool descending=false}) {
    selectCmd.order(DBOrderStatement(table).orderByField(field, descending));
    return this;
  }

  /// 分页
  /// @param page 页码
  /// @param size 数量
  /// @returns
  DBQuery paged(int page, int size) {
    selectCmd.limit(size).offset((page - 1) * size);
    return this;
  }

  @override
  String get sql {
    return selectCmd.sql;
  }
}

// ------------------------ SQL Unions --------------------------------
// export class DBUnions extends DBCommand {
//   constructor(
//   ) {
//     super()
//   }
// }

// ------------------------ SQL Insert --------------------------------
class DBInsert extends DBCommand {
  final List<DBField> fields;

  DBInsert(
      DBTable table,
      this.fields
  ) : super(table) {
    var fs = '';
    var vs = '';
    for (int i = 0; i<fields.length; i++) {
    var field = fields[i];
      params.add(field.value ?? field.defaultValue);
      fs += (i == 0) ? field.name : ', ${field.name}';
      vs += (i == 0) ? '?' : ', ?';
    }
    _sql = 'INSERT INTO ${table.tableName} ($fs) VALUES ($vs)';
  }
}

// ------------------------ SQL Create --------------------------------
class DBCreate extends DBCommand {
  final List<DBField> fields;

  DBCreate(
    DBTable table,
    this.fields
  ) : super(table) {
    var fs = '';
    for (int i = 0; i<fields.length; i++) {
      var field = fields[i];
      fs += (i == 0) ? (field.statement(this.table).sql) : (', ${field.statement(this.table).sql}');
    }
    _sql = 'CREATE TABLE IF NOT EXISTS ${table.tableName} ($fs)';
  }
}

// ------------------------ SQL Update --------------------------------
class DBUpdate extends DBCommand {
  final List<DBField> fields;
  final DBWhereStatement where;
  DBUpdate(
    DBTable table,
    this.fields,
    this.where,
  ) : super(table) {
    var fs = '';
    for (int i = 0; i<fields.length; i++) {
      var field = fields[i];
      if (field.valueChange) {
        params.add(field.value);
        fs += (fs == '') ? ('${field.name} = ?') : (', ${field.name} = ?');
      }
    }
    _sql = 'UPDATE ${table.tableName} SET $fs ${where.sql}';
    params.addAll(where.params);
  }
}

// ------------------------ SQL Delete --------------------------------
class DBDelete extends DBCommand {

  final DBWhereStatement where;

  DBDelete(DBTable table, this.where) : super(table, sql: 'DELETE FROM ${table.tableName} ${where.sql}', params:where.params);
}

// ------------------------ SQL Indexed --------------------------------
class DBIndexed extends DBCommand {
  DBIndexed(DBTable table) : super(table);

  /// 对单个字段创建索引
  /// @param field 字段
  DBCommand createForField(DBField field) {
    return createForFields([field], field.indexedName ?? field.name, unique: field.uniqueIndexed);
  }

  /// 创建联合索引
  /// @param field 字段数组
  DBCommand createForFields(List<DBField> fields, String indexedName, {bool unique=false}) {
    var fs = '';
    for (int i = 0; i<fields.length; i++) {
      fs += (i == 0) ? (fields[i].name) : (', ${fields[i].name}');
    }
    var indexSql = unique ? 'UNIQUE INDEX' : 'INDEX';
    _sql = 'CREATE $indexSql IF NOT EXISTS ${table.tableName}_$indexedName ON ${table.tableName} ($fs)';
    return this;
  }
}

class DBDrop extends DBCommand {

  DBDrop(DBTable table) : super(table);

  /// 删除索引
  DBCommand dropIndex(String indexName) {
    _sql = 'DROP INDEX IF EXISTS $indexName';
    return this;
  }

  /// 删除表
  DBCommand dropTable(String tableName) {
    _sql = 'DROP TABLE IF EXISTS $tableName';
    return this;
  }

  /// 删除视图（虚表）
  DBCommand dropView(String viewName) {
    _sql = 'DROP VIEW IF EXISTS $viewName';
    return this;
  }

}

// ------------------------ SQL Alter --------------------------------
class DBAlter extends DBCommand {

  DBAlter(DBTable table) : super(table, sql: 'ALTER TABLE ${table.tableName}');

  /// 重命名表名
  /// @param newTableName 新的表名
  DBCommand renameTable(String newTableName) {
    _sql += ' RENAME TO $newTableName';
    return this;
  }

  /// 重命名字段
  /// @param oldColumnName 旧的字段名
  /// @param newColumnName 新的字段名
  /// @returns
  DBCommand renameColumn(String oldColumnName, String newColumnName) {
    _sql += ' RENAME COLUMN $oldColumnName TO $newColumnName';
    return this;
  }

  /// 新增字段
  /// @param name 字段名
  /// @param fieldType 字段值类型
  DBCommand addColumn(String name, FieldType fieldType) {
    var type = stringForFieldType(fieldType);
    _sql += ' ADD COLUMN $name $type';
    return this;
  }
  DBCommand addColumnForField(DBField field) {
    var type = stringForFieldType(field.fieldType);
    _sql += ' ADD COLUMN ${field.name} $type';
    return this;
  }
  /// 批量新增字段
  static List<DBCommand> addColumnCommandsForFields(List<DBField> fields, DBTable table) {
    List<DBCommand> commands = [];
    for (var f in fields) {
      commands.add(DBAlter(table).addColumnForField(f));
    }
    return commands;
  }
}
