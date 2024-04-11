## 2.0.0

> **Note**: This release has breaking changes.
>
> **Motion** now requires the following:
> - Flutter >=3.19.0
> - Dart >=3.3.0
> - Java 17 and Gradle 8.1 for Android

* Added WASM support for the web by migrating to package:web ([#21](https://github.com/mrcendre/motion/pull/21) by [@raldhafiri](https://github.com/raldhafiri))
* **BREAKING CHANGE**: Added AGP 8 support ([#16](https://github.com/mrcendre/motion/pull/16) by [@pastelcode](https://github.com/pastelcode))

## 1.4.1

* Fixed "Message from native to Flutter on a non-platform thread" bug. ([#19](https://github.com/mrcendre/motion/issues/19))

## 1.4.0

* **BREAKING CHANGE:** Renamed `requiresPermission` to `isPermissionRequired` for better naming consistency.
* Allow specifying a null `damping` to disable the effect. ([#8](https://github.com/mrcendre/motion/issues/8))
* Fixed a crash after detaching FlutterEngine on iOS. ([#13](https://github.com/mrcendre/motion/issues/13))

## 1.3.3

* Fixed issues with gyroscope availability detection on iOS and Android. ([#6](https://github.com/mrcendre/motion/pull/6) by [@ekasetiawans](https://github.com/ekasetiawans))

## 1.3.2

* Added `filterQuality` to improve performances.
* Moved static members of `Motion` to `Motion.instance`.
* Drop events more frequent than the current `updateInterval`.

## 1.3.1

* Fixed an issue with native platforms lacking event and method channels. 

## 1.3.0

* Motion is now a federated plugin, depending on `motion_platform_interface` and `motion_web`.

* Removed dependency to `sensors_plus`, replaced by a custom implementation.
* Added `Motion.setUpdateInterval()` to set the widget's number of build cycles per second. Depending on platform availability, (1) the gyroscope sensor's update interval is set or (2) too frequent events are throttled to satisfy this constraint.
* Added default configurations for Web, iOS and Android on example app.
* Added support for permission detection and request on Safari iOS.
* Fixed a rendering issue with the glare effect on Safari iOS.

## 1.2.1

* Added interstitial events on Android when the gyroscope events' rate is too low.
* Updated sample app to use new constructors. ([#4](https://github.com/mrcendre/motion/pull/4) by [@sebastianbuechler](https://github.com/sebastianbuechler))
* Removed `hitTestBehavior` on MouseRegion to remain compatible with Flutter versions prior to 3.0.0. ([#4](https://github.com/mrcendre/motion/pull/4) by [@sebastianbuechler](https://github.com/sebastianbuechler))

## 1.2.0

* Added `GlareConfiguration`, `ShadowConfiguration` and `TranslationConfiguration` to allow for more customization.
* Moved the `elevation` parameter to a `Motion.elevated` constructor that computes the appropriate configurations.
* Improved performances by optimizing the widget tree and input events handling.
* Fixed some cases of jumpy rotation when the pointer is leaving or entering.

## 1.1.3

* Removed null safety warning about `WidgetsBinding.instance` across Flutter 2 and 3.

## 1.1.2

* Added explicit support for all platforms in pubspec.
* Added support for older Flutter versions.
* Set minimum Dart SDK version to 2.12.0 to increase compatibility.

## 1.1.1

* Ignore pointer on both the glare and shadow effects to allow user input on the widget.
* The glare effect's gradient now rotates from left to right, instead of bottomRight to topRight.

## 1.1.0

* Made the `controller` parameter optional in the wiget's constructor.
* Provide a `MotionController.defaultController` to use when no customization is required.
* Added a `Motion.only` constructor to disable all effects by default.
* Added support for desktop mouses using `MouseRegion` and `Listener`.
* Added dynamic translation effect.

## 1.0.1

* Minor package hygiene improvements.

## 1.0.0

* Initial release with `Motion` widget and `MotionController`.
* Supports setting a custom elevation
