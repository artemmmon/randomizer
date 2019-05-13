import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddToClipboard extends StatelessWidget {
  final Function getData;

  AddToClipboard(this.getData);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.content_copy,
        color: Colors.white,
      ),
      onPressed: _addToClipboard,
    );
  }

  /// Adds random result to clipboard
  _addToClipboard() {
    Clipboard.setData(ClipboardData(text: getData().toString()));
    //todo show centered toast
  }
}
