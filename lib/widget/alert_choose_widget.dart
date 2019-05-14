import 'package:flutter/material.dart';

class ChooserAlert extends StatelessWidget {
  final List<String> options;
  final OnChose callBack;

  ChooserAlert({this.options, this.callBack});

  @override
  Widget build(BuildContext context) {
    return null;
  }
}

typedef OnChose = String Function();
