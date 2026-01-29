import 'package:flutter/material.dart';

//TODO Make animation more obvious
/// A button that displays an animation when in a loading state.
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final double width;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.width = double.infinity,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

/// The state for the [AnimatedButton].
/// This class manages the animation controller and the fade animation.
class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  /// Initializes the animation controller and the animation.
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _animationController.repeat(reverse: true);
    }
  }

  /// Starts or stops the animation when the [isLoading] property changes.
  @override
  void didUpdateWidget(covariant AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  /// Builds the button's UI.
  ///
  /// If the button is in a loading state, it displays a fade transition on the text.
  /// Otherwise, it shows the static text.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        child: widget.isLoading
            ? FadeTransition(
          opacity: _animation,
          child: Text(widget.text),
        )
            : Text(widget.text),
      ),
    );
  }

  /// Disposes the animation controller when the widget is removed from the tree.
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
