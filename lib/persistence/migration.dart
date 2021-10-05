//  migration.dart
//  api_skyline
//
//  Created by JohnnyB0Y on 3/16/21.
//  Copyright © 2021 JohnnyB0Y. All rights reserved.

//  

// 版本管理
import 'core.dart';
import 'base.dart';
import 'command.dart';

class DBVersionTable extends DBTable {
  final fid = new DBField<int>('id', FieldType.integer, '1').primaryKey().autoIncrement();
  final fversion = new DBField<String>('migration_version', FieldType.text, '1').notNull();
  var isFirstCreate = false; // 第一次创建？

  DBVersionTable(DBSchedulable scheduler, String? flag) : super(scheduler, flag);

  String get tableName => '_db_version_table';
  DBField get usingPrimaryKey => fid;

  List<DBCommand>? tableUpgradeMigrationSteps(String version) {
    if (isFirstCreate) {
      var fields = this.dequeueWillAddFieldsForVersion('1');
      return [this.createCommand(fields)];
    }
    return null;
  }

  List<DBCommand>? tableDowngradeMigrationSteps(String version) {
    return null;
  }

  Future<String?> fetchMigrationVersion() async {
    try {
      var cmd = new DBQuery(this, fields: [fversion], where: this.primaryKeyWhereStatement());
      var items = await this.executeQuery(cmd: cmd);
      return items[0][fversion.name];
    } catch (err) {
      // 获取数据库版本出错，统一记作第一次创建数据库
      this.isFirstCreate = true;
      return null;
    }
  }

  Future<dynamic> updateMigrationVersion(String version) async {
    this.fversion.value = version;
    return this.executeUpdate(cmd: this.updateCommand(fields: [fversion]));
  }

  Future<dynamic> insertMigrationVersion(String version) async {
    this.fversion.value = version;
    var result = await this.executeInsert();
    this.isFirstCreate = false;
    return result;
  }

  @override
  List<DBField> get usingDBFields => [fid, fversion];
}


// 数据库版本迁移工具
class DBMigrator {
  late String currentVersion;
  late DBTable versionTable;

  final DBSchedulable scheduler;
  final List<DBTable> tables;

  DBMigrator(this.scheduler, this.tables) {
    this.versionTable = this.usingVersionTable();
    tables.insert(0, this.versionTable);
  }

  /// 当前需要使用的版本表
  /// @returns 迁移版本表
  DBTable usingVersionTable() {
    var t = DBVersionTable(this.scheduler, null);
    t.fid.value = 1;
    return t;
  }

  /// 获取数据库当前旧版本
  Future<String?> fetchMigrationVersion() {
    return (this.versionTable as DBVersionTable).fetchMigrationVersion();
  }

  /// 更新数据库版本
  Future<dynamic> updateMigrationVersion(String version) async {
    var t = this.versionTable as DBVersionTable;
    if (t.isFirstCreate) {
      t.isFirstCreate = false;
      return await (this.versionTable as DBVersionTable).insertMigrationVersion(version);
    }
    else {
      return await (this.versionTable as DBVersionTable).updateMigrationVersion(version);
    }
  }

  /// 取出迁移步骤命令
  /// @param version 对应版本
  /// @param upgrade 是否升级？
  /// @returns 命令数组
  List<DBCommand> dequeueMigrationStep(String version, bool isUpgrade) {
    List<DBCommand> commands = [];
    this.tables.forEach((t) {
      var cmds = isUpgrade ? t.tableUpgradeMigrationSteps(version) : t.tableDowngradeMigrationSteps(version);
      if (cmds != null) {
        commands.addAll(cmds);
      }
    });
    return commands;
  }

  /// 执行版本迁移（这里使用事务，如果某个命令执行失败，将全部回滚。可以派生子类进行自定义操作。）
  /// @param versionList 需要操作版本号数组
  /// @param isUpgrade 是否升级？
  /// @returns 最终版本号
  Future<String> executeMigrationAllSteps(List<String> versionList, bool isUpgrade) async {
    for (var i = 0; i < versionList.length; i++) {
      var version = versionList[i];
      try {
        var cmds = this.dequeueMigrationStep(version, isUpgrade);
        await this.scheduler.executeTransaction(cmds);

        print('version upgrade success: $version');
        this.updateMigrationVersion(version);
        this.currentVersion = version; // 更新当前版本号

      } catch (err) {
        // 报错直接返回，不往下升级了
        print('version upgrade failure: $version $err');
        return this.currentVersion;
      }
    }
    return this.currentVersion;
  }

  /// 检测是否执行数据库版本迁移
  /// @param versionList 历史版本号数组
  /// @returns 最终版本号
  Future<String> executeMigrationStepsOrNot(List<String> versionList) async {
    var oldVersion = await this.fetchMigrationVersion();
    var newVersion = versionList[versionList.length - 1];
    this.currentVersion = oldVersion ?? newVersion;
    // console.log(`ExecuteMigrationStepsOrNot old version: ${oldVersion}, new version: ${newVersion}`)

    if (oldVersion == newVersion) { // 版本相等，什么都不用做
      return newVersion;
    }

    if (oldVersion == null) { // 数据库第一次创建，那么从 oldVersion 一步步升级到 newVersion
      return await this.executeMigrationAllSteps(versionList, true);
    }

    List<String> migrationVersions = [];
    var isUpgrade = true;
    var start = versionList.indexOf(oldVersion);
    var end = versionList.indexOf(newVersion);
    if (double.parse(oldVersion) < double.parse(newVersion)) { // 版本过旧，升级
      for (int i = 0; i < versionList.length; i++) {
        if (i > start && i <= end) {
          migrationVersions.add(versionList[i]);
        }
      }
    }
    else if (double.parse(oldVersion) > double.parse(newVersion)) { // 版本过新，降级
      isUpgrade = false;
      for (var idx = versionList.length - 1; idx >= 0; idx--) {
        if (idx < start && idx >= end) {
          migrationVersions.add(versionList[idx]);
        }
      }
    }

    return await this.executeMigrationAllSteps(migrationVersions, isUpgrade);
  }
}

