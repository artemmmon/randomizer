import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';

class AnswersPage extends StatefulWidget {
  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  // Animation
  double _opacity = 0.0;

  // Ui
  final _textColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // Start opacity animation
    Future.delayed(Duration(milliseconds: (TransitionDuration.FAST2 * .8).toInt())).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        duration: Duration(milliseconds: TransitionDuration.FAST),
        opacity: _opacity,
        child: Container(
            alignment: Alignment(0, 0),
            margin: EdgeInsets.all(10),
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                AutoSizeText(
                  "Get an answer!",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, color: _textColor),
                ),
                SizedBox(height: 16),
              ],
            )));
  }
}
