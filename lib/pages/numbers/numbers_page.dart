import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/pages/numbers/numbers_bloc.dart';
import 'package:rxdart/rxdart.dart';

class NumbersPage extends StatefulWidget {
  final Observable<Null> onRandomClick;

  NumbersPage(this.onRandomClick);

  @override
  _NumbersPageState createState() => _NumbersPageState();
}

class _NumbersPageState extends State<NumbersPage> with TickerProviderStateMixin {
  // Bloc
  NumbersBloc _numbersBloc;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Fields
  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();
  final _inputTextSize = 32.0;
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  int get _minValue {
    try {
      return int.parse(_minController.text);
    } catch (e) {
      return 0;
    }
  }

  int get _maxValue {
    try {
      return int.parse(_maxController.text);
    } catch (e) {
      return 0;
    }
  }

  // Animation
  double _opacity = 0.0;
  AnimationController _validationAnimController;
  Animation _validationColorTween;

  // Spin number
  int _currentNumber = 0;
  int _lastNumber = 0;
  AnimationController _spinController;
  Animation<int> _spinAnimation;
  Animation<double> _scaleAnimation;

  final _maxNumberLength = 7;

  int get _maxAvailableNumber {
    var res = 0;
    for (var i = 0; i < _maxNumberLength; i++) {
      res *= 10;
      res += 9;
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    _initBloc();

    // Subscribe to random click
    _clickSubscription = widget.onRandomClick.skipWhile((_) => !mounted).listen((_) {
      _startRandomize();
    });

    // Start opacity animation
    Future.delayed(Duration(milliseconds: (TransitionDuration.FAST2 * .8).toInt())).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    _initAnimations();
    _initValidation();
  }

  @override
  void dispose() {
    super.dispose();
    _minController.dispose();
    _maxController.dispose();
    _spinController.dispose();
    _validationAnimController.dispose();
    _clickSubscription?.cancel();
  }

  _initBloc() {
    // Init Bloc
    _numbersBloc = BlocProvider.of<NumbersBloc>(context);
    // Set min, max
    if (_numbersBloc.currentState.didInit) {
      _minController.text = _numbersBloc.currentState.min.toString();
      _maxController.text = _numbersBloc.currentState.max.toString();
      _currentNumber = _numbersBloc.currentState.random;
    }

    // Dispatch new values on change
    _minController.addListener(() => _numbersBloc.dispatch(NumbersEventSetMin(_minValue)));
    _maxController.addListener(() => _numbersBloc.dispatch(NumbersEventSetMax(_maxValue)));
  }

  _startRandomize() {
    // Wait animation end
    if (_spinAnimation.status == AnimationStatus.forward) return;

    // Validate fields
    _validate();

    // Get new random
    _lastNumber = _currentNumber;
    _currentNumber = _minValue + Random().nextInt(_maxValue - (_minValue - 1));
    // Dispatch value to bloc
    _numbersBloc.dispatch(NumbersEventNewRandom(_currentNumber));

    // Set duration rely to digits difference
    final difference = (_getDigitsCount(_lastNumber) - _getDigitsCount(_currentNumber)).abs();
    print("diff: $difference");
    final durationInMillis = (300 * (difference > 0 ? (1 + (difference / 10) * 2) : 1)).toInt();
    print("durationInMillis: $durationInMillis");
    _spinController.duration = Duration(milliseconds: durationInMillis);

    // Config animation
    _spinAnimation = IntTween(begin: _lastNumber, end: _currentNumber).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.ease),
    );

    // Start Animation
    _spinController.reset();
    _spinController.forward();
  }

  int _getDigitsCount(int from) {
    if (from == 0) return 1;

    var value = from;
    var count = 0;

    while (value != 0) {
      value ~/= 10;
      count++;
    }

    print("count: $count");
    return count;
  }

  _initValidation() {
    // Validate field 0 first case
    [_minController, _minController].forEach((controller) => controller.addListener(() {
          if (controller.text.length >= 2 && controller.text.startsWith("0")) {
            controller.text = controller.text.substring(1);
          }
        }));
  }

  _validate() {
    // If min value isEmpty - set to 0
    if (_minController.text.isEmpty) {
      _minController.text = "$_minValue";
    }
    // If max value > min - set max value to min and start error validation anim
    if (_maxValue <= _minValue) {
      _validationAnimController
        ..reset()
        ..forward();
      _maxController.text = (_minValue + Random().nextInt(_maxAvailableNumber - (_minValue - 1))).toString();
    }
  }

  _initAnimations() {
    // Init spin animation
    _spinController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _spinAnimation = IntTween(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.linear),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.5), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _spinController, curve: Curves.ease));

    // Init validation animation
    _validationAnimController = AnimationController(vsync: this, duration: Duration(milliseconds: TransitionDuration.FAST2));
    _validationColorTween = TweenSequence([
      TweenSequenceItem(tween: ColorTween(begin: colorSet[0][2].withOpacity(.2), end: colorSet[0][2]), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: colorSet[0][2], end: colorSet[0][2].withOpacity(.2)), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _validationAnimController, curve: Curves.ease));
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
              color: Colors.transparent,
              child: Column(children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10),
                  child: AutoSizeText(
                    "Randomize a Number!",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                _buildInputs(context),
                Flexible(
                  child: AnimatedBuilder(
                      animation: _spinController,
                      builder: (context, widget) => Center(
                            child: Container(
                                margin: EdgeInsets.all(10),
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: AutoSizeText(
                                    _spinController.isAnimating ? _spinAnimation.value.toString() : _currentNumber.toString(),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: "CustomMonoFont", fontSize: 74, height: .5),
                                  ),
                                )),
                          )),
                )
              ]),
            )));
  }

  Widget _buildInputs(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: TextFormField(
              controller: _minController,
              focusNode: _fromFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              maxLength: _maxNumberLength,
              maxLines: 1,
              buildCounter: (BuildContext context, {int currentLength, int maxLength, bool isFocused}) => null,
              style: TextStyle(fontSize: _inputTextSize),
              cursorColor: colorSet[0][2],
              decoration: InputDecoration.collapsed(
                  filled: true,
                  hintStyle: TextStyle(color: colorSet[0][2]),
                  fillColor: colorSet[0][2].withOpacity(.2),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, style: BorderStyle.none), borderRadius: BorderRadius.circular(10)),
                  hintText: "Min"),
            ),
          ),
          SizedBox(width: 20),
          Flexible(
              child: AnimatedBuilder(
            animation: _validationAnimController,
            builder: (context, widget) => TextFormField(
                  controller: _maxController,
                  focusNode: _toFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  maxLength: _maxNumberLength,
                  maxLines: 1,
                  style: TextStyle(fontSize: _inputTextSize),
                  cursorColor: colorSet[0][2],
                  buildCounter: (BuildContext context, {int currentLength, int maxLength, bool isFocused}) => null,
                  decoration: InputDecoration.collapsed(
                      filled: true,
                      hintStyle: TextStyle(color: colorSet[0][2]),
                      fillColor: _validationColorTween?.value ?? colorSet[0][2].withOpacity(.2),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 0, style: BorderStyle.none), borderRadius: BorderRadius.circular(10)),
                      hintText: "Max"),
                ),
          )),
        ],
      ),
    );
  }
}
