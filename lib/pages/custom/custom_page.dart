import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/pages/custom/custom_bloc.dart';
import 'package:randomizer/widget/alert_widget.dart';
import 'package:rxdart/rxdart.dart';

class CustomPage extends StatefulWidget {
  final Observable<Null> onRandomClick;

  CustomPage(this.onRandomClick);

  @override
  _CustomPageState createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> with TickerProviderStateMixin {
  // Bloc
  CustomBloc _bloc;

  // Animation
  double _opacity = 0.0;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  static const _MAX_COUNT = 100;
  List<String> _data = List();
  String _random;

  // Ui
  final _textColor = Colors.white;
  final _inputColor = colorSet[1][2].withOpacity(.8);
  final _inputErrorColor = Colors.red.withOpacity(.8);
  MediaQueryData _mediaData;
  ScrollController _scrollController;

  // Fields
  final _maxNumberLength = 255;
  final _textFocusNode = FocusNode();
  final _inputTextSize = 16.0;
  final TextEditingController _textController = TextEditingController();
  AnimationController _validationAnimController;
  Animation _validationColorTween;

  @override
  void initState() {
    super.initState();
    // Init bloc
    _initBloc();

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

    // Init scroll controller
    _scrollController = ScrollController();

    // Init validation animation
    _initValidationAnim();
  }

  @override
  void dispose() {
    super.dispose();
    _clickSubscription.cancel();
    _validationAnimController.dispose();
    // Text
    _textController.dispose();
    _textFocusNode.dispose();
    // Bloc
    _bloc.dispose();
  }

  _initBloc() {
    _bloc = BlocProvider.of<CustomBloc>(context);

    // Init values
    setState(() {
      _data = List()..addAll(_bloc.currentState.items);
      _random = _bloc.currentState.random;
    });

    // Dispatch text changes to bloc
//    _textController.text = _bloc.currentState.currentText;
//    _textController.addListener(() => _bloc.dispatch(CustomEventSetText(_textController.text)));
  }

  @override
  Widget build(BuildContext context) {
    // Init media
    _mediaData = MediaQuery.of(context);

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
                        "Randomize custom data!",
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, color: _textColor),
                      ),
                    ),
                    _buildInput(),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: TransitionDuration.FAST),
                        child: _buildBody(),
                      ),
                    )
                  ],
                ))));
  }

  Widget _buildBody() {
    if (_random != null) {
      return _buildRandom(); // Random
    } else if (_data.isEmpty) {
      return _buildEmpty(); // Empty
    } else {
      return _buildChips(); // Usual
    }
  }

  void _initValidationAnim() {
    _validationAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: TransitionDuration.SLOW),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _validationAnimController.reset();
        }
      });
    _validationColorTween = TweenSequence([
      TweenSequenceItem(tween: ColorTween(begin: _inputColor, end: _inputErrorColor), weight: 1),
      TweenSequenceItem(tween: ColorTween(begin: _inputErrorColor, end: _inputColor), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _validationAnimController, curve: Curves.ease));
  }

  bool _validate() => _textController.text.isNotEmpty;

  _addItemClick() {
//    setState(() {
//      _random = null;
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//      _data.add(Random().nextInt(9999999).toString());
//    });
//    return;

    // Validate
    if (!_validate()) {
      _validationAnimController.forward();
      return;
    }

    // Clear filed focus
    _textFocusNode.unfocus();

    // Set new state
    final value = _textController.text;

    setState(() {
      _random = null;
      _data.add(value);
      _moveDown();
      _textController.clear();
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventAddItem(value));
  }

  _deleteItemClick(String value) {
    setState(() {
      // Clear filed focus
      _textFocusNode.unfocus();
      // Remove
      _data.remove(value);
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventRemoveItem(value));
  }

  _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
            title: "Delete all items",
            description: "Are you sure that you want to delete all items?",
            negativeButton: "No",
            positiveButton: "Yes",
            titleColor: colorSet[1][0],
            titleTextColor: _textColor,
            positiveAction: _clear, // On agree clear all data
          ),
    );
  }

  _clear() {
    // Clear filed focus
    _textFocusNode.unfocus();

    setState(() {
      _data.clear();
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventClearItems());
  }

  _randomize() {
    // If random != null or data is empty - do nothing
    if (_random != null || _data.isEmpty) return;

    final value = _data[Random().nextInt(_data.length)];
    setState(() {
      _random = value;
      _data.clear();
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventNewRandom(value));
  }

  Widget _buildEmpty() {
    return AutoSizeText(
      "Add some items to start.",
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, color: _textColor),
    );
  }

  Widget _buildRandom() {
    return AnimatedRandomResult(
      _random,
      textColor: _textColor,
    );
  }

  Widget _buildInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: AnimatedBuilder(
            animation: _validationAnimController,
            builder: (context, _) {
              return TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addItemClick(),
                keyboardType: TextInputType.text,
                textAlign: TextAlign.center,
                maxLength: _maxNumberLength,
                maxLines: 1,
                buildCounter: (BuildContext context, {int currentLength, int maxLength, bool isFocused}) => null,
                style: TextStyle(fontSize: _inputTextSize, color: _textColor),
                cursorColor: _textColor,
                decoration: InputDecoration.collapsed(
                    filled: true,
                    hintStyle: TextStyle(color: _textColor),
                    fillColor: _validationAnimController?.isAnimating == true ? _validationColorTween.value : _inputColor,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(width: 0, style: BorderStyle.none), borderRadius: BorderRadius.circular(10)),
                    hintText: "Enter item"),
              );
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: _addItemClick,
            icon: Icon(
              Icons.add,
              color: _textColor,
            ),
          ),
        ),
        Flexible(
          flex: 1,
          child: AnimatedOpacity(
            opacity: _random != null || _data.isEmpty ? 0 : 1,
            duration: Duration(milliseconds: TransitionDuration.FAST),
            child: IgnorePointer(
              ignoring: _random != null || _data.isEmpty,
              child: IconButton(
                onPressed: _showDeleteDialog,
                icon: Icon(Icons.delete_sweep, color: _textColor),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChips() {
    return SizedBox(
      height: double.infinity,
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 32),
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorSet[1][0], Colors.transparent, Colors.transparent, colorSet[1][0]],
//                          colors: [colorSet[1][1], colorSet[2][1]],
                stops: [0, 0.05, 0.95, 1],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
//                      blendMode: BlendMode.modulate,
            blendMode: BlendMode.dstOut,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Wrap(
                  spacing: 0,
                  children: _data.map((label) {
                    return FadedChip(label, () => _deleteItemClick(label));
                  }).toList(),
                ),
              ),
            ),
          )),
    );
  }

  _moveDown() {
    Future.delayed(Duration(milliseconds: (100).toInt())).then((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.ease,
        duration: Duration(milliseconds: TransitionDuration.FAST),
      );
    });
  }
}

class AnimatedRandomResult extends StatefulWidget {
  final String value;
  final Color textColor;

  AnimatedRandomResult(this.value, {this.textColor = Colors.black});

  @override
  _AnimatedRandomResultState createState() => _AnimatedRandomResultState();
}

class _AnimatedRandomResultState extends State<AnimatedRandomResult> with TickerProviderStateMixin {
  // Config
  final double _textSize = 32;

  // Animation
  final _animDurationInMillis = TransitionDuration.SLOW;
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Init Animation
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: _animDurationInMillis));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.8, end: 1), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    // Start Animation
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AutoSizeText(
                "${widget.value}",
                maxLines: 5,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: _textSize, color: widget.textColor),
              ),
            );
          }),
    );
  }
}

class FadedChip extends StatefulWidget {
  final String value;
  final Function onDelete;

  FadedChip(this.value, this.onDelete);

  @override
  _FadedChipState createState() => _FadedChipState();
}

class _FadedChipState extends State<FadedChip> with TickerProviderStateMixin {
  bool didInit = false;
  double _opacity = 0;

  AnimationController _controller;
  AnimationController _controller2;
  Animation<double> _scaleAnimation;
  Animation<double> _scaleAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            didInit = true;
          });
        }
      });
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDelete();
          _controller2.reset();
        }
      });
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _scaleAnimation2 = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _controller2, curve: Curves.ease));
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: !didInit ? _scaleAnimation : _scaleAnimation2,
      child: AnimatedBuilder(
          animation: _controller2,
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10).copyWith(right: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      widget.value,
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _controller2.forward();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: colorSet[1][1],
          ),
          builder: (context, child) => child),
    );
  }
}
