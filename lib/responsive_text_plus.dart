library responsive_text_plus;

import 'package:flutter/material.dart';

/// A customizable text widget that dynamically scales its font size based on
/// screen size or container dimensions, ensuring legibility across devices.
///
/// ResponsiveText automatically adjusts the font size within the defined
/// minimum and maximum bounds based on the available space or screen size.
class ResponsiveText extends StatefulWidget {
  /// The text to display.
  final String text;

  /// The style to use for this text.
  /// If null, defaults to the style from the closest [DefaultTextStyle].
  final TextStyle? style;

  /// The minimum font size constraint to use when auto-sizing text.
  final double minFontSize;

  /// The maximum font size constraint to use when auto-sizing text.
  final double maxFontSize;

  /// The step size in which the font size is being adjusted.
  final double stepGranularity;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel.
  final double textScaleFactor;

  /// An optional maximum number of lines for the text to span.
  final int? maxLines;

  /// Whether to adapt font size based on screen width.
  final bool adaptToScreenWidth;

  /// Whether to adapt font size based on container width.
  final bool adaptToContainer;

  /// Optional callback when text overflows or changes size.
  final void Function(bool didOverflow)? onFontSizeChanged;

  /// Whether to animate font size changes.
  final bool animate;

  /// The duration of the font size animation.
  final Duration animationDuration;

  /// The curve of the font size animation.
  final Curve animationCurve;

  /// Creates a responsive text widget.
  ///
  /// If [style] is null, the text will use the style from the closest
  /// [DefaultTextStyle].
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.minFontSize = 12.0,
    this.maxFontSize = 32.0,
    this.stepGranularity = 1.0,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.adaptToScreenWidth = false,
    this.adaptToContainer = true,
    this.onFontSizeChanged,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  })  : assert(minFontSize > 0),
        assert(maxFontSize > 0),
        assert(maxFontSize >= minFontSize),
        assert(stepGranularity > 0),
        textSpan = null;

  /// Creates a responsive text widget with a [TextSpan].
  ///
  /// The [textSpan] parameter must not be null.
  const ResponsiveText.rich(
    this.textSpan, {
    super.key,
    this.minFontSize = 12.0,
    this.maxFontSize = 32.0,
    this.stepGranularity = 1.0,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.adaptToScreenWidth = false,
    this.adaptToContainer = true,
    this.onFontSizeChanged,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  })  : assert(minFontSize > 0),
        assert(maxFontSize > 0),
        assert(maxFontSize >= minFontSize),
        assert(stepGranularity > 0),
        text = '',
        style = null;

  /// The text span to display for rich text.
  final TextSpan? textSpan;

  @override
  State<ResponsiveText> createState() => _ResponsiveTextState();
}

class _ResponsiveTextState extends State<ResponsiveText>
    with SingleTickerProviderStateMixin {
  double _effectiveFontSize = 0.0;
  bool _didOverflow = false;
  late AnimationController _animationController;
  Animation<double>? _fontSizeAnimation;
  double _previousFontSize = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the default text style from context
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = widget.style ?? defaultTextStyle.style;

    // Calculate the font size based on adaptation settings
    if (widget.adaptToScreenWidth) {
      final newFontSize = _calculateScreenBasedFontSize(context);
      _updateFontSize(newFontSize, effectiveTextStyle);
    } else if (widget.adaptToContainer) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final newFontSize = _calculateContainerBasedFontSize(
            constraints,
            effectiveTextStyle,
          );

          _updateFontSize(newFontSize, effectiveTextStyle);

          return _buildAnimatedText(effectiveTextStyle);
        },
      );
    } else {
      final newFontSize = effectiveTextStyle.fontSize ??
          defaultTextStyle.style.fontSize ??
          14.0;
      _updateFontSize(newFontSize, effectiveTextStyle);
    }

    // Apply the calculated font size to the text style when not using LayoutBuilder
    if (!widget.adaptToContainer) {
      return _buildAnimatedText(effectiveTextStyle);
    }

    return Container(); // This is never reached but needed for compilation
  }

  void _updateFontSize(double newFontSize, TextStyle style) {
    if (_effectiveFontSize != newFontSize) {
      if (widget.animate && _effectiveFontSize != 0.0) {
        _previousFontSize = _effectiveFontSize;
        _fontSizeAnimation = Tween<double>(
          begin: _previousFontSize,
          end: newFontSize,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: widget.animationCurve,
        ));
        _animationController.forward(from: 0.0);
      }
      _effectiveFontSize = newFontSize;
    }
  }

  Widget _buildAnimatedText(TextStyle style) {
    if (widget.animate && _fontSizeAnimation != null) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final animatedStyle = style.copyWith(
            fontSize: _fontSizeAnimation!.value,
          );
          return _buildText(animatedStyle);
        },
      );
    } else {
      final effectiveStyle = style.copyWith(
        fontSize: _effectiveFontSize,
      );
      return _buildText(effectiveStyle);
    }
  }

  Widget _buildText(TextStyle style) {
    if (widget.textSpan != null) {
      // For rich text
      final effectiveTextSpan = TextSpan(
        style: style,
        text: widget.textSpan!.text,
        children: widget.textSpan!.children,
        recognizer: widget.textSpan!.recognizer,
        semanticsLabel: widget.textSpan!.semanticsLabel,
      );

      return Text.rich(
        effectiveTextSpan,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: TextScaler.linear(widget.textScaleFactor),
        maxLines: widget.maxLines,
      );
    } else {
      // For plain text
      return Text(
        widget.text,
        style: style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: TextScaler.linear(widget.textScaleFactor),
        maxLines: widget.maxLines,
      );
    }
  }

  double _calculateScreenBasedFontSize(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate font size based on screen width
    // This is a simple linear interpolation between min and max font sizes
    // based on screen width between 320 (small phone) and 1200 (large tablet/desktop)
    const minScreenWidth = 320.0;
    const maxScreenWidth = 1200.0;

    final screenWidthFactor =
        (screenWidth - minScreenWidth) / (maxScreenWidth - minScreenWidth);

    final calculatedSize = widget.minFontSize +
        (widget.maxFontSize - widget.minFontSize) *
            screenWidthFactor.clamp(0.0, 1.0);

    // Round to the nearest step
    final steppedSize = (calculatedSize / widget.stepGranularity).round() *
        widget.stepGranularity;

    return steppedSize.clamp(widget.minFontSize, widget.maxFontSize);
  }

  double _calculateContainerBasedFontSize(
    BoxConstraints constraints,
    TextStyle style,
  ) {
    // Calculate available width
    final availableWidth = constraints.maxWidth;

    // Binary search to find the largest font size that fits
    double min = widget.minFontSize;
    double max = widget.maxFontSize;

    while (max - min > widget.stepGranularity / 2) {
      final mid = (min + max) / 2;
      final testStyle = style.copyWith(fontSize: mid);

      final didExceed = _textExceedsConstraints(
        availableWidth,
        testStyle,
      );

      if (didExceed) {
        max = mid;
      } else {
        min = mid;
      }
    }

    // Check if text overflows at the calculated size
    final finalSize = min;
    final testStyle = style.copyWith(fontSize: finalSize);

    final didOverflow = _textExceedsConstraints(
      availableWidth,
      testStyle,
    );

    // Notify if overflow state changed
    if (didOverflow != _didOverflow) {
      _didOverflow = didOverflow;
      widget.onFontSizeChanged?.call(didOverflow);
    }

    return finalSize;
  }

  bool _textExceedsConstraints(double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: widget.textSpan != null
          ? TextSpan(
              text: widget.textSpan!.text,
              children: widget.textSpan!.children,
              style: style,
            )
          : TextSpan(text: widget.text, style: style),
      textDirection: widget.textDirection ?? TextDirection.ltr,
      maxLines: widget.maxLines,
    );

    textPainter.layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines || textPainter.width > maxWidth;
  }
}

/// A widget that makes its child responsive to the available space.
///
/// This widget is useful when you want to make a widget responsive
/// to the available space, but don't want to use a [ResponsiveText] directly.
class ResponsiveTextWrapper extends StatelessWidget {
  /// The child widget to make responsive.
  final Widget child;

  /// The minimum font size constraint to use.
  final double minFontSize;

  /// The maximum font size constraint to use.
  final double maxFontSize;

  /// The step size in which the font size is being adjusted.
  final double stepGranularity;

  /// Whether to adapt font size based on screen width.
  final bool adaptToScreenWidth;

  /// Whether to adapt font size based on container width.
  final bool adaptToContainer;

  /// Optional callback when text overflows or changes size.
  final void Function(bool didOverflow)? onFontSizeChanged;

  /// Creates a responsive text wrapper.
  const ResponsiveTextWrapper({
    super.key,
    required this.child,
    this.minFontSize = 12.0,
    this.maxFontSize = 32.0,
    this.stepGranularity = 1.0,
    this.adaptToScreenWidth = false,
    this.adaptToContainer = true,
    this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveTextWrapperInherited(
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
      stepGranularity: stepGranularity,
      adaptToScreenWidth: adaptToScreenWidth,
      adaptToContainer: adaptToContainer,
      onFontSizeChanged: onFontSizeChanged,
      child: child,
    );
  }

  /// Gets the responsive text configuration from the context.
  static _ResponsiveTextWrapperInherited? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ResponsiveTextWrapperInherited>();
  }
}

class _ResponsiveTextWrapperInherited extends InheritedWidget {
  final double minFontSize;
  final double maxFontSize;
  final double stepGranularity;
  final bool adaptToScreenWidth;
  final bool adaptToContainer;
  final void Function(bool didOverflow)? onFontSizeChanged;

  const _ResponsiveTextWrapperInherited({
    required super.child,
    required this.minFontSize,
    required this.maxFontSize,
    required this.stepGranularity,
    required this.adaptToScreenWidth,
    required this.adaptToContainer,
    this.onFontSizeChanged,
  }) : super();

  @override
  bool updateShouldNotify(_ResponsiveTextWrapperInherited oldWidget) {
    return minFontSize != oldWidget.minFontSize ||
        maxFontSize != oldWidget.maxFontSize ||
        stepGranularity != oldWidget.stepGranularity ||
        adaptToScreenWidth != oldWidget.adaptToScreenWidth ||
        adaptToContainer != oldWidget.adaptToContainer;
  }
}
