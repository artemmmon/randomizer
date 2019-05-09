import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:rxdart/rxdart.dart';

class CustomPage extends StatefulWidget {
  final Observable<Null> onRandomClick;

  CustomPage(this.onRandomClick);

  @override
  _CustomPageState createState() => _CustomPageState();
}

class _CustomPageState extends State<CustomPage> {
  // Animation
  double _opacity = 0.0;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  static const _MAX_COUNT = 100;
  List<String> _data = List();

  // Ui
  final _textColor = Colors.black;
  MediaQueryData _mediaData;
  ScrollController _scrollController;

  // Fields
  final _maxNumberLength = 255;
  final _textFocusNode = FocusNode();
  final _inputTextSize = 16.0;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Subscribe to random click
    _clickSubscription = widget.onRandomClick.skipWhile((_) => !mounted).listen((_) {
//      setState(() {
//        //todo limit max count and show dialog if max count reached
//        _data.add(Random().nextInt(99999999).toString());
//        _moveDown();
//      });
    });

    // Start opacity animation
    Future.delayed(Duration(milliseconds: (TransitionDuration.FAST2 * .8).toInt())).then((_) {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Init scroll controller
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _clickSubscription.cancel();
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
                          child: _data.isEmpty ? _buildEmpty() : _buildChips()),
                    )
                  ],
                ))));
  }

  _addItemClick() {
    //todo validation
    setState(() {
      _data.add(_textController.text);
      _moveDown();
      _textController.clear();
    });
  }

  _clearClick() {
    setState(() {
      _data.clear();
    });
  }

  Widget _buildEmpty() {
    return AutoSizeText(
      "Enter some items to start.",
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, color: _textColor),
    );
  }

  Widget _buildInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: TextField(
            controller: _textController,
            focusNode: _textFocusNode,
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
                fillColor: colorSet[1][2].withOpacity(.8),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none), borderRadius: BorderRadius.circular(10)),
                hintText: "Enter item"),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: _addItemClick,
            icon: Icon(Icons.add),
          ),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
            onPressed: _clearClick,
            icon: Icon(Icons.delete_sweep),
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
                stops: [0, 0.1, 0.9, 1],
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
                    return FadedChip(label, () {
                      setState(() {
                        _data.remove(label);
                      });
                    });
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
//          child: Chip(
//            elevation: 2,
//            onDeleted: () {
//              _controller2.forward();
//            },
//            deleteIcon: Icon(Icons.close),
//            deleteButtonTooltipMessage: null,
//            label: Text(
//              widget.value,
//              softWrap: true,
//              maxLines: 3,
//              overflow: TextOverflow.ellipsis,
//            ),
//            backgroundColor: colorSet[1][1],
//          ),

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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _controller2.forward();
                    },
                    child: Icon(
                      Icons.close,
                      size: 24,
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
