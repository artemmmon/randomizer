import 'dart:convert';

import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';

import 'custom_list_model.dart';

class CustomListBean {
  final SqfliteAdapter _adapter;

  CustomListBean(this._adapter);

  final String tableName = "custom_lists";
  final IntField id = IntField("_id");
  final StrField name = StrField("name");
  final StrField items = StrField("items");

  dispose() {
    if (_adapter?.connection != null) {
      _adapter?.close();
    }
  }

  Future<Null> _createTable() async {
    final st = Create(tableName, ifNotExists: true).addAutoPrimaryInt(id.name).addStr("name").addStr("items");

    await _adapter.createTable(st);
  }

  Future insert(CustomListModel model) async {
    await _openDbIfNeeded();
    await _createTable();

    Insert insert = Insert(tableName)..set(name, model.name)..set(items, model.getItemsAsJson());

    var sameItemsId = await _getIdByItems(model.items);
    if (sameItemsId != null) {
      await delete(sameItemsId);
    }
    return _adapter.insert(insert);
  }

  Future delete(int id) async {
    await _openDbIfNeeded();
    await _createTable();

    Remove remove = Remove(tableName)..where(eqInt(this.id.name, id));
    return await _adapter.remove(remove);
  }

  Future<List<CustomListModel>> getAll() async {
    await _openDbIfNeeded();
    await _createTable();

    Find finder = Find(tableName);
    // Get all rows
    List<Map> rows = await _adapter.find(finder);

    List<CustomListModel> res = List();

    // Map rows to list
    for (Map row in rows) {
      String name = row["name"];
      List<dynamic> items = jsonDecode(row["items"]);
      res.add(CustomListModel(name, items.map((value) => value as String).toList()));
    }

    return res;
  }

  Future<CustomListModel> _getByItems(List<String> items) async {
    await _openDbIfNeeded();
    await _createTable();

    Find finder = Find(tableName)
      ..selAll()
      ..where(eq(this.items.name, jsonEncode(items)));
    List<Map> rows = await _adapter.find(finder);
    if (rows.isNotEmpty) {
      Map row = rows.first;
      return CustomListModel(row["name"], items.map((value) => value).toList());
    } else {
      return null;
    }
  }

  Future<int> _getIdByItems(List<String> items) async {
    await _openDbIfNeeded();
    await _createTable();

    Find finder = Find(tableName)
      ..selAll()
      ..where(eq(this.items.name, jsonEncode(items)));
    List<Map> rows = await _adapter.find(finder);
    if (rows.isNotEmpty) {
      Map row = rows.first;
      return row["${this.id.name}"];
    } else {
      return null;
    }
  }

  Future<void> _openDbIfNeeded() async {
    if (_adapter.connection == null || !_adapter.connection.isOpen) {
      return _adapter.connect();
    } else {
      return null;
    }
  }
}
