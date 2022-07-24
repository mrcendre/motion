# Motion for Flutter widgets

[![pub package](https://img.shields.io/pub/v/motion.svg)](https://pub.dev/packages/motion)


This package adds a new `Motion` widget that applies a gyroscope-based effect to Flutter widgets. On desktop or when the gyroscope in not available, the effect is based on the pointer's hovering.


!["Demo of the Motion plugin"](https://github.com/mrcendre/motion/raw/main/example/gifs/demo.gif)

To see examples of the following effect on a device or simulator:

```bash
cd example/
flutter run --release
```

# How to use 

First, add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  motion: ^<latest-version>
```

Then, wrap your target widget as child of a `Motion` widget. You may optionally provide a `MotionController` instance that will hold your widget's transformations. The simplest usage of this widget is the following :

```dart

import 'package:motion/motion.dart';

...

return Motion(child: myWidget);

```

## Elevation

To remain consistent with the Material design language, you can pass an **elevation** parameter to the widget by using the `Motion.elevated` constructor. 

It will influence the offset, opacity and blurriness of the shadow. Possible values for `elevation` range between `0` and `100`.

!["Elevations examples"](https://github.com/mrcendre/motion/raw/main/example/gifs/elevations.gif)

_Comparing different elevation values_

## Shadow

The **shadow** is optional and depends, when using the `Motion.elevated` constructor, on the `elevation` value. The higher the `elevation`, the blurrier and the lower from behind the widget the shadow will get. The amplitude of the shadow's movement also depends on the widget's elevation. This aims to achieve the same behavior as Material design language's notion of elevation.

!["Shadow effect comparison"](https://github.com/mrcendre/motion/raw/main/example/gifs/shadow.gif)

_Comparing with and without the shadow effect_

By default, the `shadow` is enabled but you can disable it by constructing the `Motion` widget with `shadow: null` or by using the `Motion.only` constructor. 

## Glare

The **glare** effect is also optional. It is a very subtle gradient overlay that confers a reflective feel to the widget.

!["Glare effect comparison"](https://github.com/mrcendre/motion/raw/main/example/gifs/glare.gif)

_Comparing with and without the glare effect_

Also enabled by default, you can disable this effect by constructing the `Motion` widget with `glare: false` or by using the `Motion.only` constructor.

## Custom configurations

You can provide custom configurations for the glare, shadow and translation effects by passing `GlareConfiguration`, `ShadowConfiguration` and `TranslationConfiguration` to the `Motion` and `Motion.only` constructors. When omitted, the default values will be used, unless if you use the `Motion.only` constructor.


# Issues

If you are having any problem with the Motion package, you can file an issue on the package repo's [issue tracker](https://github.com/mrcendre/motion/issues/).

Please make sure that your concern hasn't already been addressed in the 'Closed' section.

# Credits

This package was developed with ♥ by [@mrcendre](https://cendre.me/).