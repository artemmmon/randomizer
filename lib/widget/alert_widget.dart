import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';

class CustomDialog extends StatelessWidget {
  // Data
  final String title, description, positiveButton, negativeButton;
  final Function positiveAction, negativeAction;

  // Sizes
  final double _padding = 16.0;

  CustomDialog(
      {@required this.title,
      @required this.description,
      @required this.positiveButton,
      @required this.negativeButton,
      this.positiveAction,
      this.negativeAction});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(_padding).copyWith(top: _padding + (_padding / 2)).copyWith(bottom: 0),
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
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 24.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              SizedBox(height: 16.0),
              ButtonBar(alignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                FlatButton(
                  onPressed: () {
                    if (negativeAction != null) {
                      negativeAction();
                    }
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    negativeButton,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    if (positiveAction != null) {
                      positiveAction();
                    }
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    positiveButton,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
