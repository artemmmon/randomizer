import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/pages/custom/custom_bloc.dart';
import 'package:randomizer/pages/custom/random_result_widget.dart';
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
  var _animateChips = false;
  var _animateRandom = false;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  static const _MAX_COUNT = 50;
  List<String> _data = List();
  String _random;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

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
  }

  _initBloc() {
    _bloc = BlocProvider.of<CustomBloc>(context);

    // Init values
    _data = List()..addAll(_bloc.currentState.items);
    _random = _bloc.currentState.random;

    // Dispatch text changes to bloc
    _textController.text = _bloc.currentState.currentText;
    _textController.addListener(() => _bloc.dispatch(CustomEventSetText(_textController.text)));
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

  _addItemClick([bool fast = false]) {
    if (fast) {
      addToBlocDummy(Random random) async {
        for (var i = 0; i < 5; i++) {
          _bloc.dispatch(CustomEventAddItem(random.nextInt(9999999).toString()));
        }
      }

      final random = Random();
      setState(() {
        _random = null;
        _data.add(random.nextInt(9999999).toString());
        _data.add(random.nextInt(9999999).toString());
        _data.add(random.nextInt(9999999).toString());
        _data.add(random.nextInt(9999999).toString());
        _data.add(random.nextInt(9999999).toString());
      });
      addToBlocDummy(random);
      return;
    }

    // Validate
    if (!_validate()) {
      _validationAnimController.forward();
      return;
    }

    // Turn on chip reveal animation
    _animateChips = true;
    // Set new state
    final value = _textController.text;

    var index = _data.length;
    setState(() {
      _random = null;
      _data.add(value);
      _moveDown();
      _textController.clear();
    });

    if (index > 0) {
      _listKey.currentState.insertItem(
        index,
        duration: Duration(milliseconds: TransitionDuration.FAST),
      );
    }

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventAddItem(value));
  }

  _deleteItemClick(String value) {
    setState(() {
      // Clear filed focus
      _textFocusNode.unfocus();
      // Remove
      var index = _data.indexOf(value);
      _data.removeAt(index);
      _listKey.currentState.removeItem(index, (BuildContext context, Animation<double> animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
            axisAlignment: 0.0,
            child: _buildItem(value),
          ),
        );
      }, duration: Duration(milliseconds: TransitionDuration.FAST));
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
            positiveAction: _clear, // On agree clear all data
          ),
    );
  }

  _clear() {
    // Clear filed focus
    _textFocusNode.unfocus();

    setState(() {
      _data.clear();
//      _listKey.currentState.
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventClearItems());
  }

  _randomize() {
    // If random != null or data is empty - do nothing
    if (_random != null || _data.isEmpty) return;

    // Turn on animation
    _animateRandom = true;

    // Set new state
    final value = _data[Random().nextInt(_data.length)];
    setState(() {
      _random = value;
      _data.clear();
    });

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventNewRandom(value));
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

  Widget _buildBody() {
    if (_random != null) {
      return _buildRandom(); // Random
    } else if (_data.isEmpty) {
      return _buildEmpty(); // Empty
    } else {
      return _buildContent(); // Usual
    }
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
      animate: _animateRandom,
    );
  }

  Widget _buildInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
//        Flexible(
//            flex: 1,
//            child: AnimatedOpacity(
//              opacity: _data.length >= _MAX_COUNT ? 0 : 1,
//              duration: Duration(milliseconds: TransitionDuration.FAST),
//              child: IgnorePointer(
//                ignoring: _data.length >= _MAX_COUNT,
//                child: IconButton(
//                  onPressed: () => _addItemClick(true),
//                  icon: Icon(
//                    Icons.add,
//                    color: _textColor,
//                  ),
//                ),
//              ),
//            )),
        Expanded(
            flex: 4,
            child: AnimatedOpacity(
                opacity: _data.length >= _MAX_COUNT ? 0 : 1,
                duration: Duration(milliseconds: TransitionDuration.FAST),
                child: IgnorePointer(
                  ignoring: _data.length >= _MAX_COUNT,
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
                        decoration: InputDecoration(
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                            hintStyle: TextStyle(color: _textColor),
                            fillColor: _validationAnimController?.isAnimating == true ? _validationColorTween.value : _inputColor,
                            border: OutlineInputBorder(
                                borderSide: BorderSide(width: 0, style: BorderStyle.none),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter item"),
                      );
                    },
                  ),
                ))),
        Flexible(
            flex: 1,
            child: AnimatedOpacity(
              opacity: _data.length >= _MAX_COUNT ? 0 : 1,
              duration: Duration(milliseconds: TransitionDuration.FAST),
              child: IgnorePointer(
                ignoring: _data.length >= _MAX_COUNT,
                child: GestureDetector(
                  ////////
                  // TEMPORARY FOR TEST
                  ////////
                  onLongPress: () => _addItemClick(true),
                  ////////

                  child: IconButton(
                    onPressed: _addItemClick,
                    icon: Icon(
                      Icons.add,
                      color: _textColor,
                    ),
                  ),
                ),
              ),
            )),
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

  Widget _buildContent() {
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
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: AnimatedList(
                  key: _listKey,
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  initialItemCount: _data.length,
                  itemBuilder: (context, position, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        var offset = _mediaData.size.width * 2;
                        return Transform.translate(
                          offset: Offset(-offset + (animation.value * offset), 0),
                          child: _buildItem(_data[position]),
                        );
                      },
                    );
                  }),
            ),
          )),
    );
  }

  Widget _buildItem(String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10).copyWith(right: 5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _deleteItemClick(value);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorSet[1][1],
    );
  }
}
