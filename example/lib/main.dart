import 'package:flutter/material.dart';
import 'package:responsive_text_plus/flutter_responsive_text.dart';


void main() {
  runApp(const ResponsiveTextDemo());
}

class ResponsiveTextDemo extends StatelessWidget {
  const ResponsiveTextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResponsiveText Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _containerWidth = 300;
  bool _adaptToContainer = true;
  bool _adaptToScreenWidth = false;
  bool _animate = false;
  double _minFontSize = 12;
  double _maxFontSize = 32;
  int? _maxLines;
  TextOverflow _overflow = TextOverflow.clip;
  bool _useRichText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ResponsiveText Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo section
            const Text(
              'Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Container with responsive text
            Center(
              child: Container(
                width: _containerWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _useRichText
                    ? ResponsiveText.rich(
                        TextSpan(
                          text: 'This is ',
                          children: const [
                            TextSpan(
                              text: 'rich text',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' with responsive sizing that adapts to container width.',
                            ),
                          ],
                        ),
                        minFontSize: _minFontSize,
                        maxFontSize: _maxFontSize,
                        adaptToContainer: _adaptToContainer,
                        adaptToScreenWidth: _adaptToScreenWidth,
                        animate: _animate,
                        maxLines: _maxLines,
                        overflow: _overflow,
                        textAlign: TextAlign.center,
                      )
                    : ResponsiveText(
                        'This is a responsive text that adapts to ${_adaptToContainer ? 'container' : 'screen'} width.',
                        minFontSize: _minFontSize,
                        maxFontSize: _maxFontSize,
                        adaptToContainer: _adaptToContainer,
                        adaptToScreenWidth: _adaptToScreenWidth,
                        animate: _animate,
                        maxLines: _maxLines,
                        overflow: _overflow,
                        textAlign: TextAlign.center,
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Controls section
            const Text(
              'Controls',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Container width slider
            const Text('Container Width'),
            Slider(
              value: _containerWidth,
              min: 100,
              max: 500,
              divisions: 40,
              label: _containerWidth.round().toString(),
              onChanged: (value) {
                setState(() {
                  _containerWidth = value;
                });
              },
            ),

            // Min font size slider
            const Text('Min Font Size'),
            Slider(
              value: _minFontSize,
              min: 8,
              max: 24,
              divisions: 16,
              label: _minFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _minFontSize = value;
                });
              },
            ),

            // Max font size slider
            const Text('Max Font Size'),
            Slider(
              value: _maxFontSize,
              min: 16,
              max: 48,
              divisions: 32,
              label: _maxFontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _maxFontSize = value;
                });
              },
            ),

            // Adaptation options
            const Text('Adaptation Mode'),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Container'),
                    value: _adaptToContainer,
                    onChanged: (value) {
                      setState(() {
                        _adaptToContainer = value ?? true;
                        if (_adaptToContainer) {
                          _adaptToScreenWidth = false;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Screen'),
                    value: _adaptToScreenWidth,
                    onChanged: (value) {
                      setState(() {
                        _adaptToScreenWidth = value ?? false;
                        if (_adaptToScreenWidth) {
                          _adaptToContainer = false;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            // Animation toggle
            CheckboxListTile(
              title: const Text('Animate Size Changes'),
              value: _animate,
              onChanged: (value) {
                setState(() {
                  _animate = value ?? false;
                });
              },
            ),

            // Rich text toggle
            CheckboxListTile(
              title: const Text('Use Rich Text'),
              value: _useRichText,
              onChanged: (value) {
                setState(() {
                  _useRichText = value ?? false;
                });
              },
            ),

            // Max lines options
            const Text('Max Lines'),
            SegmentedButton<int?>(
              segments: const [
                ButtonSegment(value: null, label: Text('No Limit')),
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
              ],
              selected: {_maxLines},
              onSelectionChanged: (Set<int?> selection) {
                setState(() {
                  _maxLines = selection.first;
                });
              },
            ),

            // Overflow options
            const SizedBox(height: 16),
            const Text('Overflow Handling'),
            SegmentedButton<TextOverflow>(
              segments: const [
                ButtonSegment(value: TextOverflow.clip, label: Text('Clip')),
                ButtonSegment(
                  value: TextOverflow.ellipsis,
                  label: Text('Ellipsis'),
                ),
                ButtonSegment(value: TextOverflow.fade, label: Text('Fade')),
              ],
              selected: {_overflow},
              onSelectionChanged: (Set<TextOverflow> selection) {
                setState(() {
                  _overflow = selection.first;
                });
              },
            ),

            const SizedBox(height: 32),

            // Comparison section
            const Text(
              'Comparison',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Regular Text vs ResponsiveText
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Regular Text',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'This is a regular text widget that does not adapt to container width.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'ResponsiveText',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const ResponsiveText(
                          'This is a responsive text widget that adapts to container width.',
                          minFontSize: 10,
                          maxFontSize: 18,
                          adaptToContainer: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
