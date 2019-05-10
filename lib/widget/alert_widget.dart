import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';

class CustomDialog extends StatelessWidget {
  // Data
  final String title, description, positiveButton, negativeButton;
  final Color titleColor, titleTextColor;
  final Function positiveAction, negativeAction;

  // Sizes
  final double _padding = 16.0;
  final double _labelHeight = 54;

  CustomDialog(
      {@required this.title,
      @required this.description,
      @required this.positiveButton,
      @required this.negativeButton,
      this.positiveAction,
      this.negativeAction,
      this.titleColor = Colors.white,
      this.titleTextColor = Colors.black});

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
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: _labelHeight,
            left: _padding,
            right: _padding,
          ),
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
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomRight,
                child: ButtonBar(children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      if (negativeAction != null) {
                        negativeAction();
                      }
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Text(negativeButton),
                  ),
                  FlatButton(
                    onPressed: () {
                      if (positiveAction != null) {
                        positiveAction();
                      }
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Text(positiveButton),
                  ),
                ]),
              ),
            ],
          ),
        ),
        Positioned(
          left: _padding * 3,
          right: _padding * 3,
          top: -(_labelHeight / 2),
          child: SizedBox(
            height: _labelHeight,
            child: Container(
              alignment: Alignment(0, 0),
              decoration: BoxDecoration(
                color: titleColor,
                borderRadius: BorderRadius.circular(_labelHeight / 2),
              ),
              child: AutoSizeText(
                title,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, color: titleTextColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
