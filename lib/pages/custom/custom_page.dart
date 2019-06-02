import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/data/custom_list_model.dart';
import 'package:randomizer/pages/custom/custom_bloc.dart';
import 'package:randomizer/widget/alert_choose_widget.dart';
import 'package:randomizer/widget/alert_widget.dart';
import 'package:randomizer/widget/helper/add_to_clipboard_widget.dart';
import 'package:randomizer/widget/random_result_widget.dart';
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

  CustomState get _currentState => _bloc.currentState;

  List<String> get _items => _currentState.customListModel.items;

  // Animation
  double _opacity = 0.0;
  var _animateRandom = false;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Data
  static const _MAX_COUNT = 50;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  // Ui
  final _textColor = Colors.white;
  final _inputColor = colorSet[1][2].withOpacity(.2);
  final _inputErrorColor = Colors.red.withOpacity(.5);
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
    _clickSubscription =
        widget.onRandomClick.skipWhile((_) => !mounted).throttleTime(Duration(milliseconds: TransitionDuration.SLOW)).listen((_) {
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

    // Dispatch text changes to bloc
    _textController.text = _currentState.currentText;
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
                    _buildInput(context),
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

  bool _validate() => _textController.text.trim().isNotEmpty;

  _addItemClick() {
    // Validate
    if (!_validate()) {
      _validationAnimController.forward();
      return;
    }

    // Set new state
    final value = _textController.text.trim();
    var index = _items.length;

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventAddItem(value));
    // Make ui to react
    setState(() {
      _moveDown();
    });
    _textController.clear();

    if (index > 0) {
      _listKey.currentState.insertItem(
        index,
        duration: Duration(milliseconds: TransitionDuration.FAST),
      );
    }
  }

  _deleteItemClick(String value) {
    setState(() {
      // Clear filed focus
      _textFocusNode.unfocus();
      // Remove
      var index = _items.indexOf(value);
      _listKey.currentState.removeItem(index, (BuildContext context, Animation<double> animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
          child: SizeTransition(
            sizeFactor: CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
            axisAlignment: 0.0,
            child: _buildItem(index, value),
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

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventClearItems());
  }

  _randomize() {
    // If data is empty - do nothing
    if (_items.isEmpty) return;

    // Turn on animation
    _animateRandom = true;

    // Randomize
    final list = _items;
    final value = list[Random().nextInt(list.length)];

    // Dispatch event to bloc
    _bloc.dispatch(CustomEventNewRandom(value));
  }

  _showHistoryDialog(BuildContext context) async {
    // Fetch data from db
    final List<CustomListModel> data = await _bloc.fetchAllLists();
    // If data is empty show toast
    if (data.isEmpty) {
      showToast("You don't have any history yet.");
      return;
    }

    String getName(CustomListModel item) {
      var items = item.items;
      var content = "[${items.getRange(0, items.length >= 3 ? 3 : items.length).join(", ")}]";
      if (items.length > 3) {
        content = content.replaceFirst("]", "...]", content.length - 1);
      }
//      return "${item.name} $content";
      return "$content";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => ChooserDialog(
          title: "Select list from history",
          callBack: (key) {
            // Make list
            _reinitializeList(data[key].items);
            // Emit new event
            _bloc.dispatch(CustomEventPickModel(data[key]));
            // Close dialog
            Navigator.of(context).pop();
          },
          fixed: false,
          options: data.asMap().map((key, item) => MapEntry(
              key,
              Text(
                getName(item),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 16),
              )))),
    );
  }

  _reinitializeList(List<String> newData) {
    // If list isn't initialized yet - do nothing
    if (_listKey.currentState == null) return;
    // Remove all items
    for (int i = _items.length - 1; i >= 0; i--) {
      _listKey.currentState.removeItem(i, (BuildContext context, Animation<double> animation) {
        return Container();
      });
    }
    // Add new items
    for (int i = 0; i < newData.length; i++) {
      _listKey.currentState.insertItem(i, duration: Duration(milliseconds: 0));
    }
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
    return BlocBuilder(
        bloc: _bloc,
        builder: (context, state) {
          if (_currentState.random != null) {
            return _buildRandom(); // Random
          } else if (_items.isEmpty) {
            return _buildEmpty(); // Empty
          } else {
            return _buildContent(); // Usual
          }
        });
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedRandomResult(
          _currentState.random,
          textColor: _textColor,
          animate: _animateRandom,
        ),
        SizedBox(height: 16),
        AddToClipboard(() => _currentState.random),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, CustomState state) {
        if (state.random != null) {
          return Padding(
            padding: EdgeInsets.only(top: 12),
            child: InkWell(
                onTap: () {
                  _bloc.dispatch(CustomEventClearRandom());
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: colorSet[1][2].withOpacity(.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
//                    Icon(
//                      Icons.arrow_back,
//                      color: Colors.white,
//                    ),
                      Text(
//                      "Back to data: ${state.customListModel.name}",
                        "Back to data",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                      ),
                    ],
                  ),
                )),
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      _showHistoryDialog(context);
                    },
                    icon: Icon(
                      Icons.list,
                      color: _textColor,
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: AnimatedOpacity(
                      opacity: _items.length >= _MAX_COUNT ? 0 : 1,
                      duration: Duration(milliseconds: TransitionDuration.FAST),
                      child: IgnorePointer(
                        ignoring: _items.length >= _MAX_COUNT,
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
                                  fillColor:
                                      _validationAnimController?.isAnimating == true ? _validationColorTween.value : _inputColor,
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
                    opacity: _items.length >= _MAX_COUNT ? 0 : 1,
                    duration: Duration(milliseconds: TransitionDuration.FAST),
                    child: IgnorePointer(
                      ignoring: _items.length >= _MAX_COUNT,
                      child: IconButton(
                        onPressed: _addItemClick,
                        icon: Icon(
                          Icons.add,
                          color: _textColor,
                        ),
                      ),
                    ),
                  )),
              Flexible(
                flex: 1,
                child: AnimatedOpacity(
                  opacity: _currentState.random != null || _items.isEmpty ? 0 : 1,
                  duration: Duration(milliseconds: TransitionDuration.FAST),
                  child: IgnorePointer(
                    ignoring: _currentState.random != null || _items.isEmpty,
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
      },
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
                colors: [Colors.black, Colors.transparent, Colors.transparent, Colors.black],
//                          colors: [colorSet[0][0], colorSet[0][1]],
//                stops: [0, 0.05, 0.95, 1],
                stops: [0, 0.07, 0.93, 1],
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
                  initialItemCount: _items.length,
                  itemBuilder: (context, position, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        var offset = _mediaData.size.width * 2;
                        return Transform.translate(
                          offset: Offset(-offset + (animation.value * offset), 0),
                          child: _buildItem(position, _items[position]),
                        );
                      },
                    );
                  }),
            ),
          )),
    );
  }

  Widget _buildItem(int index, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: Row(
          children: <Widget>[
            Text(
              "${(index + 1)}. ",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
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
