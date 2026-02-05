import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isLoading) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      widget.isLoading ? _controller.repeat() : _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Color.lerp(
              primaryColor,
              Colors.black,
              0.1,
            ),
            disabledForegroundColor: Colors.white,
            elevation: widget.isLoading ? 0 : 2,
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: widget.isLoading
              ? _buildShimmeringText(theme.colorScheme.onPrimary)
              : Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildShimmeringText(Color textColor) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
              colors: [
                textColor.withAlpha(128),
                textColor.withAlpha(128),
                textColor,
                textColor.withAlpha(128),
                textColor.withAlpha(128)
              ],
              transform: _SlidingGradientTransform(slidePercent: _shimmerAnimation.value),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
