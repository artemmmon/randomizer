import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/config/icons.dart';
import 'package:randomizer/widget/alert_choose_widget.dart';
import 'package:rxdart/rxdart.dart';

class GamblePage extends StatefulWidget {
  final Observable<Null> onRandomClick;

  GamblePage(this.onRandomClick);

  @override
  _GamblePageState createState() => _GamblePageState();
}

class _GamblePageState extends State<GamblePage> with TickerProviderStateMixin {
  // Bloc
//  CustomBloc _bloc;

  // Animation
  double _opacity = 0.0;
  final _animDurationInMillis = TransitionDuration.SLOW;
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  int _diceAmount = 3;
  List<int> _random = [1, 2, 3, 4];
  final _dices = const [
    CustomIcons.dice_1,
    CustomIcons.dice_2,
    CustomIcons.dice_3,
    CustomIcons.dice_4,
    CustomIcons.dice_5,
    CustomIcons.dice_6,
  ];

  // Helpers
  final _randomizer = Random();

  // Ui
  final _textColor = Colors.white;
  final double _diceSize = 124;
  final double _padding = 8;

  @override
  void initState() {
    super.initState();
    // Init bloc
//    _initBloc();

    // Subscribe to random click
    _clickSubscription = widget.onRandomClick.skipWhile((_) => !mounted).listen((_) {
      _randomize();
    });

    // Start opacity animation
    Future.delayed(Duration(milliseconds: (TransitionDuration.FAST2 * .8).toInt())).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    _initAnimation();
  }

  _initAnimation() {
    // Init Animation
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: _animDurationInMillis))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _controller.reset();
      });
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  void dispose() {
    super.dispose();
    _clickSubscription?.cancel();
    _controller?.dispose();
  }

  _randomize() {
    // If animation still going - do nothing
    if (_controller.isAnimating) return;

    _controller.forward();
    // Set new random when dices won't be visible
    Future.delayed(Duration(milliseconds: (_animDurationInMillis * .15).toInt()), () {
      setState(() {
        for (int i = 0; i < 4; i++) {
          _random[i] = _randomizer.nextInt(6);
        }
      });
    });
  }

  _showChooserDialog() {
    final double iconSize = 36;
    final double space = 4;

    Icon getIcon(int index) => Icon(_dices[_random[index]], size: iconSize);

    showDialog(
      context: context,
      builder: (BuildContext context) => ChooserDialog(
            title: "Choose dice amount",
            callBack: (value) {
              setState(() {
                _diceAmount = value;
              });
              Navigator.of(context).pop();
            },
            options: {
              1: Container(width: double.infinity, child: getIcon(0)),
              2: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[getIcon(0), SizedBox(width: space), getIcon(1)]),
              3: Column(
                children: <Widget>[
                  Container(width: double.infinity, child: getIcon(0)),
                  SizedBox(height: space),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[getIcon(1), SizedBox(width: space), getIcon(2)])
                ],
              ),
              4: Column(
                children: <Widget>[
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[getIcon(0), SizedBox(width: space), getIcon(1)]),
                  SizedBox(height: space),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[getIcon(2), SizedBox(width: space), getIcon(3)])
                ],
              ),
            },
          ),
    );
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
                            onTap: _showChooserDialog,
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
                        child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildContent(),
                              );
                            })),
                  ],
                ))));
  }

  ///Shows dices rely to dice amount
  _buildContent() {
    switch (_diceAmount) {
      case 1:
        return Icon(
          _dices[_random[0]],
          size: _diceSize,
          color: Colors.white,
        );
        break;
      case 2:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(_padding),
              child: Icon(
                _dices[_random[0]],
                size: _diceSize,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_padding),
              child: Icon(
                _dices[_random[1]],
                size: _diceSize,
                color: Colors.white,
              ),
            ),
          ],
        );
        break;
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(_padding),
              child: Icon(
                _dices[_random[0]],
                size: _diceSize,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: Icon(
                    _dices[_random[1]],
                    size: _diceSize,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: Icon(
                    _dices[_random[2]],
                    size: _diceSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
        break;
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: Icon(
                    _dices[_random[0]],
                    size: _diceSize,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: Icon(
                    _dices[_random[1]],
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
                    _dices[_random[2]],
                    size: _diceSize,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(_padding),
                  child: Icon(
                    _dices[_random[3]],
                    size: _diceSize,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        );
        break;
    }
  }
}
