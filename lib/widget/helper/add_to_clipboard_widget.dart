import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

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

  /// Adds random result to clipboard and shows toast
  _addToClipboard() {
    Clipboard.setData(ClipboardData(text: getData().toString()));
    showToast("Data saved to clipboard", duration: Duration(milliseconds: 1500));
  }
}
