import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/config/icons.dart';

class GamblePage extends StatefulWidget {
  @override
  _GamblePageState createState() => _GamblePageState();
}

class _GamblePageState extends State<GamblePage> {
  // Bloc
//  CustomBloc _bloc;

  // Animation
  double _opacity = 0.0;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  int _diceAmount = 1;
  final dices = [
    CustomIcons.dice_1,
    CustomIcons.dice_2,
    CustomIcons.dice_3,
    CustomIcons.dice_4,
    CustomIcons.dice_5,
    CustomIcons.dice_6,
  ];

  // Ui
  final _textColor = Colors.white;
  final double _diceSize = 124;
  final double _padding = 8;

  // Fields

  @override
  void initState() {
    super.initState();
    // Init bloc
//    _initBloc();

    // Subscribe to random click
//    _clickSubscription = widget.onRandomClick.skipWhile((_) => !mounted).listen((_) {
//      _randomize();
//    });

    // Start opacity animation
    Future.delayed(Duration(milliseconds: (TransitionDuration.FAST2 * .8).toInt())).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clickSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        duration: Duration(milliseconds: TransitionDuration.FAST),
        opacity: _opacity,
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
                alignment: Alignment(0, 0),
                margin: EdgeInsets.all(10),
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      "Roll the dice!",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, color: _textColor),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Dices:",
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8).copyWith(right: 0),
                              decoration: BoxDecoration(
                                color: colorSet[2][2].withOpacity(.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "$_diceAmount",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(_padding),
                                child: Icon(
                                  dices[Random().nextInt(dices.length)],
                                  size: _diceSize,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(_padding),
                                child: Icon(
                                  dices[Random().nextInt(dices.length)],
                                  size: _diceSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(_padding),
                                child: Icon(
                                  dices[Random().nextInt(dices.length)],
                                  size: _diceSize,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(_padding),
                                child: Icon(
                                  dices[Random().nextInt(dices.length)],
                                  size: _diceSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
