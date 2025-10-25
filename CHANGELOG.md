## 1.0.3

* Added validation to prevent both `adaptToScreenWidth` and `adaptToContainer` from being true simultaneously
* Enhanced error handling with clear assertion messages for invalid parameter combinations
* Improved API consistency between ResponsiveText and ResponsiveTextWrapper classes

## 1.0.2

* Fixed private type in public API linting issue
* Made ResponsiveTextWrapperInherited class public for better API compliance
* Improved code quality and static analysis compliance
* Enhanced pub.dev package scoring

## 1.0.1

* Added animation support for smooth font size transitions
* Enhanced rich text support with TextSpan
* Added comprehensive example app
* Improved test coverage
* Added ResponsiveTextWrapper for more flexible usage

## 1.0.0

Initial release of the ResponsiveText package with the following features:

* Dynamic font scaling based on screen size or container dimensions
* Configurable minimum and maximum font size constraints
* Step granularity control for fine-tuning font size adjustments
* Multi-line text support with maxLines parameter
* Overflow handling with customizable behavior
* Screen-based and container-based adaptation modes
* Callback support for overflow state changes
