import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ChooserDialog extends StatelessWidget {
  // Data
  final String title;
  final Map<dynamic, Widget> options;
  final OnChose callBack;

  // Ui
  final double _padding = 16.0;
  final Color _textColor = Colors.black;

  ChooserDialog({this.title, this.options, this.callBack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  _dialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_padding).copyWith(top: _padding + (_padding / 2)),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(_padding),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          AutoSizeText(
            title,
            maxLines: 1,
            style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          ...options.values
              .map((value) => Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () => callBack(options.entries.firstWhere((entry) => entry.value == value).key),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: value,
                    ),
                  )))
              .toList()
        ],
      ),
    );
  }
}

typedef OnChose = Function(dynamic selectedValue);
