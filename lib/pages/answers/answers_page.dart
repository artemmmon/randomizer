import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomizer/config/app_localization.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/widget/helper/add_to_clipboard_widget.dart';
import 'package:randomizer/widget/random_result_widget.dart';
import 'package:rxdart/rxdart.dart';

import 'answers_bloc.dart';

class AnswersPage extends StatefulWidget {
  final Observable<Null> onRandomClick;

  AnswersPage(this.onRandomClick);

  @override
  _AnswersPageState createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  // Bloc
  AnswersBloc _bloc;

  // Click subscription
  StreamSubscription _clickSubscription;

  // Animation
  double _opacity = 0.0;
  var _animateRandom = false;

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

    // Init bloc
    _bloc = BlocProvider.of<AnswersBloc>(context);

    // Subscribe to random click
    _clickSubscription =
        widget.onRandomClick.skipWhile((_) => !mounted).throttleTime(Duration(milliseconds: TransitionDuration.SLOW)).listen((_) {
      _randomize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _clickSubscription?.cancel();
  }

  _randomize() {
    _animateRandom = true;
    _bloc.dispatch(AnswersEventNewRandom());
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
                  AppLocalizations.of(context).translate("answers_title"),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, color: _textColor),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Center(child: _buildContent()),
                ),
              ],
            )));
  }

  Widget _buildContent() {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, AnswersState state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedRandomResult(
              state.answer,
              textColor: _textColor,
              animate: _animateRandom,
            ),
            SizedBox(height: 16),
            AddToClipboard(() => state.answer),
          ],
        );
      },
    );
  }
}
