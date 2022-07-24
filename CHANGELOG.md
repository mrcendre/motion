## 1.2.0

* Added [GlareConfiguration], [ShadowConfiguration] and [TranslationConfiguration] to allow for more customization.
* Moved the [elevation] parameter to a [Motion.elevated] constructor that computes the appropriate configurations.
* Improved performances by optimizing the widget tree and input events handling.
* Fixed some cases of jumpy rotation when the pointer is leaving or entering.

## 1.1.3

* Removed null safety warning about [WidgetsBinding.instance] across Flutter 2 and 3.

## 1.1.2

* Added explicit support for all platforms in pubspec.
* Added support for older Flutter versions.
* Set minimum Dart SDK version to 2.12.0 to increase compatibility.

## 1.1.1

* Ignore pointer on both the glare and shadow effects to allow user input on the widget.
* The glare effect's gradient now rotates from left to right, instead of bottomRight to topRight.

## 1.1.0

* Made the [controller] parameter optional in the wiget's constructor.
* Provide a [MotionController.defaultController] to use when no customization is required.
* Added a [Motion.only] constructor to disable all effects by default.
* Added support for desktop mouses using [MouseRegion] and [Listener].
* Added dynamic translation effect.

## 1.0.1

* Minor package hygiene improvements.

## 1.0.0

* Initial release with 'Motion' widget and 'MotionController'.
* Supports setting a custom elevation
