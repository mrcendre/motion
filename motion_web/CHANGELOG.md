## 2.0.1

- Add support for `web` package version 1.1.0

## 2.0.0

> **Note**: This release has breaking changes.
>
> **motion_web** now requires the following:
> - Flutter >=3.19.0
> - Dart >=3.3.0

* Added WASM support for the web by migrating to package:web ([#21](https://github.com/mrcendre/motion/pull/21) by [@raldhafiri](https://github.com/raldhafiri))

## 1.4.0

* **BREAKING CHANGE:** Renamed `requiresPermission` to `isPermissionRequired` for better naming consistency.
* Allow specifying a null `damping` to disable the effect. ([#8](https://github.com/mrcendre/motion/issues/8))
* Fixed a crash after detaching FlutterEngine on iOS. ([#13](https://github.com/mrcendre/motion/issues/13))

## 1.3.3

* Fixed issues with gyroscope availability detection on iOS and Android. ([#6](https://github.com/mrcendre/motion/pull/6))

## 1.3.2

- Updated `motion_platform_interface` to v1.3.2.

## 1.3.1


- Fixed an issue with some native platforms lacking event and method channels implementations. 

## 1.3.0

- Initial release
