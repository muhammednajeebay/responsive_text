import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_text_plus/responsive_text_plus.dart';

void main() {
  testWidgets('ResponsiveText renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ResponsiveText(
              'Test',
              minFontSize: 10.0,
              maxFontSize: 20.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the text is rendered.
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('ResponsiveText adapts to container width',
      (WidgetTester tester) async {
    // Build with constrained width
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              child: ResponsiveText(
                'This is a long text that should adapt to the container width',
                minFontSize: 10.0,
                maxFontSize: 20.0,
                adaptToContainer: true,
              ),
            ),
          ),
        ),
      ),
    );

    // Get the text widget
    final Text textWidget = tester.widget(find.byType(Text));

    // Verify that the font size is within bounds
    expect(textWidget.style?.fontSize, lessThanOrEqualTo(20.0));
    expect(textWidget.style?.fontSize, greaterThanOrEqualTo(10.0));
  });

  testWidgets('ResponsiveText.rich renders correctly',
      (WidgetTester tester) async {
    // Build our app with rich text
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ResponsiveText.rich(
              TextSpan(
                text: 'Hello ',
                children: [
                  TextSpan(
                    text: 'World',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              minFontSize: 10.0,
              maxFontSize: 20.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the rich text is rendered
    expect(find.byType(RichText), findsOneWidget);
  });

  testWidgets('ResponsiveText handles overflow callback',
      (WidgetTester tester) async {
    bool didOverflow = false;

    // Build with very small width to force overflow
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 50,
              child: ResponsiveText(
                'This text should overflow even at minimum font size',
                minFontSize: 8.0,
                maxFontSize: 12.0,
                adaptToContainer: true,
                maxLines: 1,
                onFontSizeChanged: (overflow) {
                  didOverflow = overflow;
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Wait for layout calculations
    await tester.pumpAndSettle();

    // Verify that overflow callback was triggered
    expect(didOverflow, isTrue);
  });

  testWidgets('ResponsiveTextWrapper applies configuration to children',
      (WidgetTester tester) async {
    // Build with wrapper
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ResponsiveTextWrapper(
              minFontSize: 12.0,
              maxFontSize: 24.0,
              child: Text('Test'),
            ),
          ),
        ),
      ),
    );

    // Verify that the wrapper is rendered
    expect(find.byType(ResponsiveTextWrapper), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  group('ResponsiveText calculations', () {
    test('Screen-based font size calculation', () {
      // Create a test state
      final state = _ResponsiveTextState();

      // Mock a BuildContext with MediaQuery
      final context = _MockBuildContext();

      // Test the calculation
      final fontSize = state._calculateScreenBasedFontSize(context);

      // Verify the result is within bounds
      expect(fontSize, lessThanOrEqualTo(20.0));
      expect(fontSize, greaterThanOrEqualTo(10.0));
    });
  });
}

// Mock classes for testing
class _MockBuildContext extends Fake implements BuildContext {
  MediaQueryData get mediaQuery => const MediaQueryData(
        size: Size(360, 640),
        devicePixelRatio: 2.0,
      );
}

class _ResponsiveTextState extends State<ResponsiveText> {
  @override
  Widget build(BuildContext context) => Container();

  double _calculateScreenBasedFontSize(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate font size based on screen width
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
}
