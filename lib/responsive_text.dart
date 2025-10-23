library responsive_text;

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

  /// Creates a responsive text widget.
  ///
  /// If [style] is null, the text will use the style from the closest
  /// [DefaultTextStyle].
  const ResponsiveText(
    this.text, {
    Key? key,
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
  })  : assert(minFontSize > 0),
        assert(maxFontSize > 0),
        assert(maxFontSize >= minFontSize),
        assert(stepGranularity > 0),
        super(key: key);

  @override
  State<ResponsiveText> createState() => _ResponsiveTextState();
}

class _ResponsiveTextState extends State<ResponsiveText> {
  double _effectiveFontSize = 0.0;
  bool _didOverflow = false;

  @override
  Widget build(BuildContext context) {
    // Get the default text style from context
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle effectiveTextStyle = widget.style ?? defaultTextStyle.style;
    
    // Calculate the font size based on adaptation settings
    if (widget.adaptToScreenWidth) {
      _effectiveFontSize = _calculateScreenBasedFontSize(context);
    } else if (widget.adaptToContainer) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          _effectiveFontSize = _calculateContainerBasedFontSize(
            constraints,
            effectiveTextStyle,
          );
          
          // Apply the calculated font size to the text style
          effectiveTextStyle = effectiveTextStyle.copyWith(
            fontSize: _effectiveFontSize,
          );
          
          return _buildText(effectiveTextStyle);
        },
      );
    } else {
      _effectiveFontSize = effectiveTextStyle.fontSize ?? 
          defaultTextStyle.style.fontSize ?? 
          14.0;
    }
    
    // Apply the calculated font size to the text style when not using LayoutBuilder
    if (!widget.adaptToContainer) {
      effectiveTextStyle = effectiveTextStyle.copyWith(
        fontSize: _effectiveFontSize,
      );
    }
    
    return _buildText(effectiveTextStyle);
  }

  Widget _buildText(TextStyle style) {
    return Text(
      widget.text,
      style: style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
    );
  }

  double _calculateScreenBasedFontSize(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate font size based on screen width
    // This is a simple linear interpolation between min and max font sizes
    // based on screen width between 320 (small phone) and 1200 (large tablet/desktop)
    const minScreenWidth = 320.0;
    const maxScreenWidth = 1200.0;
    
    final screenWidthFactor = (screenWidth - minScreenWidth) / 
        (maxScreenWidth - minScreenWidth);
    
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
    // Start with the maximum font size
    double fontSize = widget.maxFontSize;
    
    // Calculate available width
    final availableWidth = constraints.maxWidth;
    
    // Binary search to find the largest font size that fits
    double min = widget.minFontSize;
    double max = widget.maxFontSize;
    
    while (max - min > widget.stepGranularity / 2) {
      final mid = (min + max) / 2;
      final testStyle = style.copyWith(fontSize: mid);
      
      final textPainter = TextPainter(
        text: TextSpan(text: widget.text, style: testStyle),
        textDirection: widget.textDirection ?? TextDirection.ltr,
        maxLines: widget.maxLines,
      );
      
      textPainter.layout(maxWidth: availableWidth);
      
      if (textPainter.didExceedMaxLines || 
          textPainter.width > availableWidth) {
        max = mid;
      } else {
        min = mid;
      }
    }
    
    // Check if text overflows at the calculated size
    final finalSize = min;
    final testStyle = style.copyWith(fontSize: finalSize);
    
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: testStyle),
      textDirection: widget.textDirection ?? TextDirection.ltr,
      maxLines: widget.maxLines,
    );
    
    textPainter.layout(maxWidth: availableWidth);
    
    final didOverflow = textPainter.didExceedMaxLines || 
        textPainter.width > availableWidth;
    
    // Notify if overflow state changed
    if (didOverflow != _didOverflow) {
      _didOverflow = didOverflow;
      widget.onFontSizeChanged?.call(didOverflow);
    }
    
    return finalSize;
  }
}
