import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:randomizer/config/global_config.dart';
import 'package:randomizer/config/icons.dart';
import 'package:randomizer/pages/answers/answers_bloc.dart';
import 'package:randomizer/pages/answers/answers_page.dart';
import 'package:randomizer/pages/custom/custom_bloc.dart';
import 'package:randomizer/pages/custom/custom_page.dart';
import 'package:randomizer/pages/gamble/gamble_bloc.dart';
import 'package:randomizer/pages/gamble/gamble_page.dart';
import 'package:randomizer/pages/numbers/numbers_bloc.dart';
import 'package:randomizer/pages/numbers/numbers_page.dart';
import 'package:rxdart/subjects.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_localization.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      movingOnWindowChange: true,
      backgroundColor: Colors.white.withOpacity(.9),
      position: ToastPosition.center,
      textStyle: TextStyle(
        fontFamily: "CustomFont",
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: "CustomFont",
          primaryTextTheme: Typography().white,
          textTheme: Typography().white,
          textSelectionColor: Colors.white.withOpacity(.2),
          textSelectionHandleColor: Colors.white,
        ),
        home: HomePage(),
        // List all of the app's supported locales here
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ru', 'RU'),
          Locale('uk', 'UA'),
        ],
        // These delegates make sure that the localization data for the proper language is loaded
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],
        // Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Bloc
  final NumbersBloc _numbersBloc = NumbersBloc();
  final CustomBloc _customBloc = CustomBloc();
  final GambleBloc _gambleBloc = GambleBloc();
  final AnswersBloc _answersBloc = AnswersBloc();

  // Page data
  int _currentPageIndex = 0;
  int _previousPageIndex = 0;

  // Click subject
  final PublishSubject<Null> _clickSubject = PublishSubject();

  // Icon animation
  AnimationController _animationControllerIcon1, _animationControllerIcon2, _animationControllerIcon3, _animationControllerIcon4;
  Animation<double> _sizeTween1, _sizeTween2, _sizeTween3, _sizeTween4;
  Animation _colorTween1, _colorTween2, _colorTween3, _colorTween4;

  // Reveal animation
  Animation<double> _revealAnimation;
  AnimationController _revealController;
  Animation _fabColorAnimation;
  Animation<double> _fabSizeAnimation;
  double _fraction = 0.0;
  Offset _revealOffset = Offset.zero;

  final _fabKey = GlobalKey();
  final _fabInitialKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    //set portrait orientation only
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    super.dispose();
    // Animation
    _animationControllerIcon1.dispose();
    _animationControllerIcon2.dispose();
    _animationControllerIcon3.dispose();
    _animationControllerIcon4.dispose();
    _revealController.dispose();
    // Click
    _clickSubject.close();
    // Bloc
    _numbersBloc.dispose();
    _customBloc.dispose();
    _gambleBloc.dispose();
    _answersBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Animate BottomNavBar
    _handleBottomMenuAnimation();

    return BlocProviderTree(
      blocProviders: [
        BlocProvider<NumbersBloc>(bloc: _numbersBloc),
        BlocProvider<CustomBloc>(bloc: _customBloc),
        BlocProvider<GambleBloc>(bloc: _gambleBloc),
        BlocProvider<AnswersBloc>(bloc: _answersBloc),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(color: colorSet[_previousPageIndex][0]),
        child: CustomPaint(
            painter: RevealProgressButtonPainter(
                _fraction, MediaQuery.of(context).size, _revealOffset, colorSet[_currentPageIndex][0]),
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              backgroundColor: Colors.transparent,
              body: SafeArea(
                  child: Column(
                children: <Widget>[
                  _buildContent(context),
                ],
              )),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: AnimatedBuilder(
                  animation: _revealController,
                  builder: (context, widget) => Transform.scale(
                      scale: _fabSizeAnimation?.value ?? 1,
                      child: FloatingActionButton(
                        onPressed: () {
                          // Take focus on fab
                          FocusScope.of(context).requestFocus(FocusNode());
                          // Emit new click value to subject
                          _clickSubject.add(null);
                        },
                        key: _fabInitialKey,
                        backgroundColor: _fabColorAnimation?.value ?? colorSet[_currentPageIndex][1],
                        child: Icon(
                          CustomIcons.dices,
                          size: 32,
                          color: Colors.black,
                        ),
                        elevation: 2.0,
                      ))),
              bottomNavigationBar: BottomAppBar(
                clipBehavior: Clip.antiAlias,
                color: Colors.transparent,
                elevation: 0,
                child: _buildBottomNav(context),
                shape: CircularNotchedRectangle(),
              ),
            )),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    Widget getChild() {
      switch (_currentPageIndex) {
        case 0:
          return NumbersPage(_clickSubject);
          break;
        case 1:
          return CustomPage(_clickSubject);
          break;
        case 2:
          return GamblePage(_clickSubject);
          break;
        case 3:
          return AnswersPage(_clickSubject);
          break;
        default:
          return NumbersPage(_clickSubject);
      }
    }

    return Expanded(
        child: AnimatedSwitcher(
      duration: Duration(milliseconds: TransitionDuration.FAST ~/ 2),
      child: getChild(),
    ));
  }

  _selectPage(int newIndex, Offset revealOffset) {
    if (_currentPageIndex == newIndex) return;
    setState(() {
      _previousPageIndex = _currentPageIndex;
      _currentPageIndex = newIndex;
      _revealOffset = _getFabOffset();
      reveal();
    });
  }

  Widget _buildBottomNav(BuildContext context) {
    final cornerRadius = Radius.circular(20);
    return Card(
      margin: EdgeInsets.all(10).copyWith(top: 0),
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(cornerRadius)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animationControllerIcon1,
              builder: (BuildContext context, Widget child) {
                var key = GlobalKey();
                return IconButton(
                    key: key,
                    icon: Icon(
                      CustomIcons.sort_numeric,
                      size: _sizeTween1.value,
                    ),
                    color: _colorTween1.value,
                    highlightColor: Colors.transparent,
                    splashColor: colorSet[0][1].withAlpha((255 * 0.25).toInt()),
                    onPressed: () {
                      var renderBox = (key.currentContext.findRenderObject() as RenderBox);
                      var offset = renderBox.size.height / 2;
                      _selectPage(0, renderBox.localToGlobal(Offset(offset, offset)));
                    });
              },
            ),
            AnimatedBuilder(
              animation: _animationControllerIcon2,
              builder: (BuildContext context, Widget child) {
                var key = GlobalKey();
                return IconButton(
                    key: key,
                    icon: Icon(
                      CustomIcons.list,
                      size: _sizeTween2.value,
                    ),
                    color: _colorTween2.value,
                    highlightColor: Colors.transparent,
                    splashColor: colorSet[1][1].withAlpha((255 * 0.25).toInt()),
                    onPressed: () {
                      var renderBox = (key.currentContext.findRenderObject() as RenderBox);
                      var offset = renderBox.size.height / 2;
                      _selectPage(1, renderBox.localToGlobal(Offset(offset, offset)));
                    });
              },
            ),
            SizedBox(
              width: 24,
            ),
            AnimatedBuilder(
              animation: _animationControllerIcon3,
              builder: (BuildContext context, Widget child) {
                var key = GlobalKey();
                return IconButton(
                    key: key,
                    icon: Icon(
                      CustomIcons.dice,
                      size: _sizeTween3.value,
                    ),
                    color: _colorTween3.value,
                    highlightColor: Colors.transparent,
                    splashColor: colorSet[2][1].withAlpha((255 * 0.25).toInt()),
                    onPressed: () {
                      var renderBox = (key.currentContext.findRenderObject() as RenderBox);
                      var offset = renderBox.size.height / 2;
                      _selectPage(2, renderBox.localToGlobal(Offset(offset, offset)));
                    });
              },
            ),
            AnimatedBuilder(
              animation: _animationControllerIcon4,
              builder: (BuildContext context, Widget child) {
                var key = GlobalKey();
                return IconButton(
                    key: key,
                    icon: Icon(
                      CustomIcons.help,
                      size: _sizeTween4.value,
                    ),
                    color: _colorTween4.value,
                    highlightColor: Colors.transparent,
                    splashColor: colorSet[3][1].withAlpha((255 * 0.25).toInt()),
                    onPressed: () {
                      var renderBox = (key.currentContext.findRenderObject() as RenderBox);
                      var offset = renderBox.size.height / 2;
                      _selectPage(3, renderBox.localToGlobal(Offset(offset, offset)));
                    });
              },
            )
          ],
        ),
      ),
    );
  }

  _handleBottomMenuAnimation() {
    switch (_currentPageIndex) {
      case 0:
        _animationControllerIcon1.forward();
        _animationControllerIcon2.reverse();
        _animationControllerIcon3.reverse();
        _animationControllerIcon4.reverse();
        break;
      case 1:
        _animationControllerIcon1.reverse();
        _animationControllerIcon2.forward();
        _animationControllerIcon3.reverse();
        _animationControllerIcon4.reverse();
        break;
      case 2:
        _animationControllerIcon1.reverse();
        _animationControllerIcon2.reverse();
        _animationControllerIcon3.forward();
        _animationControllerIcon4.reverse();
        break;
      case 3:
        _animationControllerIcon1.reverse();
        _animationControllerIcon2.reverse();
        _animationControllerIcon3.reverse();
        _animationControllerIcon4.forward();
        break;
    }
  }

  _initAnimations() {
    final iconColor = Colors.black;
    final iconSize = 24.0;
    final iconSizeSelected = 32.0;

    _animationControllerIcon1 = AnimationController(vsync: this, duration: Duration(milliseconds: TransitionDuration.FAST));
    _animationControllerIcon2 = AnimationController(vsync: this, duration: Duration(milliseconds: TransitionDuration.FAST));
    _animationControllerIcon3 = AnimationController(vsync: this, duration: Duration(milliseconds: TransitionDuration.FAST));
    _animationControllerIcon4 = AnimationController(vsync: this, duration: Duration(milliseconds: TransitionDuration.FAST));

    _revealController = AnimationController(
      duration: const Duration(milliseconds: TransitionDuration.FAST2),
      vsync: this,
    );

    _sizeTween1 = Tween<double>(begin: iconSize, end: iconSizeSelected).animate(
      CurvedAnimation(parent: _animationControllerIcon1, curve: Curves.ease),
    );
    _sizeTween2 = Tween<double>(begin: iconSize, end: iconSizeSelected).animate(
      CurvedAnimation(parent: _animationControllerIcon2, curve: Curves.ease),
    );
    _sizeTween3 = Tween<double>(begin: iconSize, end: iconSizeSelected).animate(
      CurvedAnimation(parent: _animationControllerIcon3, curve: Curves.ease),
    );
    _sizeTween4 = Tween<double>(begin: iconSize, end: iconSizeSelected).animate(
      CurvedAnimation(parent: _animationControllerIcon4, curve: Curves.ease),
    );

    _colorTween1 = ColorTween(begin: iconColor, end: colorSet[0][0]).animate(_animationControllerIcon1);
    _colorTween2 = ColorTween(begin: iconColor, end: colorSet[1][0]).animate(_animationControllerIcon2);
    _colorTween3 = ColorTween(begin: iconColor, end: colorSet[2][0]).animate(_animationControllerIcon3);
    _colorTween4 = ColorTween(begin: iconColor, end: colorSet[3][0]).animate(_animationControllerIcon4);

    _fabSizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.4), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _revealController, curve: Curves.ease));
  }

  void reveal() {
    _revealAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.linear),
    )..addListener(() {
        setState(() {
          _fraction = _revealAnimation.value;
        });
      });

    _fabColorAnimation =
        ColorTween(begin: colorSet[_previousPageIndex][2], end: colorSet[_currentPageIndex][2]).animate(_revealController);

    _revealController.reset();
    _revealController.forward();
  }

  Offset _getFabOffset() {
    var context = _fabInitialKey.currentContext ?? _fabKey.currentContext;

    var renderBox = (context.findRenderObject() as RenderBox);
    var offset = renderBox.size.height / 2;
    return renderBox.localToGlobal(Offset(offset, offset));
  }
}

class RevealProgressButtonPainter extends CustomPainter {
  double _fraction = 0.0;
  Size _screenSize;
  Color _color;
  Offset _offset;

  RevealProgressButtonPainter(this._fraction, this._screenSize, this._offset, this._color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    var finalRadius = sqrt(pow(_screenSize.width / 1.1, 2) + pow(_screenSize.height / 1.1, 2));
    var radius = 10 + finalRadius * _fraction;

    canvas.drawCircle(_offset, radius, paint);
  }

  @override
  bool shouldRepaint(RevealProgressButtonPainter oldDelegate) {
    return oldDelegate._fraction != _fraction;
  }
}
