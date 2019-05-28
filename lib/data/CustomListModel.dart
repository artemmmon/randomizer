import 'dart:convert';

class CustomListModel {
  String name;
  List<String> items;

  CustomListModel(this.name, this.items);

  String getItemsAsJson() => jsonEncode(items);
}
