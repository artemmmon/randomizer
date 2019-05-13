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
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      child: AutoSizeText(
                        "Roll the dice!",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, color: _textColor),
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
//                    _buildInput(),
//                    _buildBody(),
                  ],
                ))));
  }
}
