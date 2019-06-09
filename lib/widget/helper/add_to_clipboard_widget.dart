import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:randomizer/config/app_localization.dart';

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
      onPressed: () => _addToClipboard(context),
    );
  }

  /// Adds random result to clipboard and shows toast
  _addToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: getData().toString()));
    showToast(AppLocalizations.of(context).translate("data_saved_message"), duration: Duration(milliseconds: 1500));
  }
}
