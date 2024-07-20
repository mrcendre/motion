import 'package:web/web.dart' as web;

class Scripts {
  static void load() {
    dynamic scriptText = detectionScript.minified;
      
    web.document.body?.append(web.HTMLScriptElement()
      ..type = 'application/javascript'
      ..innerHTML = scriptText);
  }
}

extension Minifier on String {
  String get minified =>
      this.withoutComments.replaceAll('\n', '').replaceAll('  ', '');

  String get withoutComments {
    List<String> lines = this.split('\n');

    lines.removeWhere((line) => line.trimLeft().startsWith('//'));

    return lines.join('\n');
  }
}

const detectionScript = '''
/// Test user agent to detect Safari iOS
function isSafariMobile() {

    var ua = window.navigator.userAgent;
    var iOS = !!ua.match(/iPad/i) || !!ua.match(/iPhone/i);
    var webkit = !!ua.match(/WebKit/i);
    var chrome = ua.match(/CriOS/i);

    return iOS && webkit && !chrome;

}

/// A method indicating whether the Gyroscope API is available in the current context.
function isGyroscopeApiAvailable() {

    if (typeof Gyroscope === "undefined") return false;

    var gyro = new Gyroscope();

    return gyro.x != null || gyro.y != null || gyro.z != null;

}

/// A method indicating whether the DeviceMotionEvent API is available in the current context.
function isDeviceMotionApiAvailable() {

    if (typeof DeviceMotionEvent === "undefined") return false;

    /// If no permission is required, we sample events to determine availability.
    if (requiresDeviceMotionEventPermission() === false) {

        var anEvent;
        window.addEventListener("devicemotion", (event) => {
            anEvent = event;
        });

        return typeof anEvent === "object";
    }

    return true;
}

/// A method indicating whether the DeviceMotionEvent API requires a permission.
function requiresDeviceMotionEventPermission() {
    if (isDeviceMotionApiAvailable) {
        // feature detect
        if (typeof DeviceMotionEvent.requestPermission === "function") {
            return true;
        }
    }
    return false;
}


/// A method that checks whether the permission to access the DeviceMotionEvent API was already granted.
async function evaluatePermission() {

    var result;

    try {
        result = await DeviceMotionEvent.requestPermission();
    } catch (e) {
        /// An error may occur when we are checking if the permission was already granted,
        /// without an user gesture triggering this check; it is expected behavior.
    }

    return result === "granted";

}

/// A method to request the permission to use the DeviceMotionEvent API if needed.
///
/// Returns a boolean indicating if gyroscope permission needed, and if so if it has been granted.
function requestDeviceMotionEventPermission() {
    console.log("requestDeviceMotionEventPermission - start");

    if (typeof DeviceMotionEvent !== "undefined") {
        /// Feature detection
        if (typeof DeviceMotionEvent.requestPermission === "function") {
            return DeviceMotionEvent.requestPermission()
                .then((permissionState) => {
                    console.log(
                        "requestDeviceMotionEventPermission - permissionState: ",
                        permissionState
                    );

                    return permissionState == "granted";
                })
                .catch((err) => {
                    console.warn("requestDeviceMotionEventPermission - Error: ", err);
                    return false;
                });
        } else {
            /// Handle regular lack of permission requirement on non iOS 13+ devices
            return true;
        }
    } else {
        console.log("Your device does not support motion events.");
        return false;
    }
}
''';
