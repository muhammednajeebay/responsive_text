# ResponsiveText

A customizable text widget that dynamically scales its font size based on screen size or container dimensions, ensuring legibility across devices.

## Features

- **Dynamic Font Scaling**: Automatically adjusts font size based on available space
- **Min/Max Bounds**: Set minimum and maximum font size constraints
- **Multi-line Support**: Control text wrapping with maxLines parameter
- **Adaptive Spacing**: Customize text alignment and direction
- **Overflow Handling**: Choose how text behaves when it doesn't fit
- **Screen Size Awareness**: Scale text based on device screen dimensions
- **Container Awareness**: Adapt text to fit within its container

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_responsive_text: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:flutter_responsive_text/responsive_text.dart';

ResponsiveText(
  'Hello World',
  minFontSize: 12.0,
  maxFontSize: 24.0,
)
```

### Container-based Scaling

```dart
Container(
  width: 200,
  child: ResponsiveText(
    'This text will scale to fit the container width',
    minFontSize: 10.0,
    maxFontSize: 20.0,
    adaptToContainer: true,
  ),
)
```

### Screen-based Scaling

```dart
ResponsiveText(
  'This text scales based on screen width',
  minFontSize: 14.0,
  maxFontSize: 32.0,
  adaptToScreenWidth: true,
)
```

### With Overflow Handling

```dart
ResponsiveText(
  'This text will show ellipsis if it overflows',
  minFontSize: 12.0,
  maxFontSize: 18.0,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  onFontSizeChanged: (didOverflow) {
    if (didOverflow) {
      print('Text is overflowing!');
    }
  },
)
```

## Additional information

- **GitHub Repository**: [Click Here](https://github.com/muhammednajeebay/responsive_text)
- **Bug Reports**: Please file issues at the GitHub repository
- **Feature Requests**: We welcome suggestions for new features
- **Contributions**: Pull requests are welcome
