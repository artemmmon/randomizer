import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/config/global_config.dart';

class AnimatedRandomResult extends StatefulWidget {
  final String value;
  final Color textColor;

  // Config
  final bool animate;

  AnimatedRandomResult(this.value, {Key key, this.textColor = Colors.black, this.animate = true}) : super(key: key);

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
    if (widget.animate) {
      _initAnimation();
      // Start Animation
      _controller.forward();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(AnimatedRandomResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Init animation if need
      if (_controller == null) {
        _initAnimation();
      }
      // Start animation
      _controller.reset();
      _controller.forward();
    }
  }

  _initAnimation() {
    // Init Animation
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: _animDurationInMillis));
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.8), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.8, end: 1), weight: 1)
    ].toList())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget.animate
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildContent(),
                );
              })
          : _buildContent(),
    );
  }

  _buildContent() {
    return AutoSizeText(
      "${widget.value}",
      maxLines: 5,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: _textSize, color: widget.textColor),
    );
  }
}
