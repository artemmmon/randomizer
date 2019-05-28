import 'dart:convert';

import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';

import 'CustomListModel.dart';

class CustomListBean {
  final SqfliteAdapter _adapter;

  CustomListBean(this._adapter);

  final String tableName = "custom_Lists";
  final IntField id = IntField("_id");
  final StrField name = StrField("name");
  final StrField items = StrField("items");

  dispose() {
    _adapter?.close();
  }

  Future<Null> _createTable() async {
    final st = Create(tableName, ifNotExists: true).addAutoPrimaryInt("_id").addStr("name").addStr("items");

    await _adapter.createTable(st);
  }

  Future insert(CustomListModel model) async {
    await _openDbIfNeeded();
    await _createTable();

    Insert insert = Insert(tableName);
    insert.set(name, model.name);
    insert.set(items, model.getItemsAsJson());

    return _adapter.insert(insert);
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

  Future<void> _openDbIfNeeded() async {
    if (_adapter.connection == null || !_adapter.connection.isOpen) {
      return _adapter.connect();
    } else {
      return null;
    }
  }
}
