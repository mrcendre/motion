// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

var _eventChannels: [String: FlutterEventChannel] = [:]
var _streamHandlers: [String: MotionStreamHandler] = [:]
var _isCleanUp = false

public class MTMotionPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let gyroscopeStreamHandler = MTGyroscopeStreamHandler()
        let gyroscopeStreamHandlerName = "me.cendre.motion/gyroscope"
        let gyroscopeChannel = FlutterEventChannel(
                name: gyroscopeStreamHandlerName,
                binaryMessenger: registrar.messenger()
        )
        gyroscopeChannel.setStreamHandler(gyroscopeStreamHandler)
        _eventChannels[gyroscopeStreamHandlerName] = gyroscopeChannel
        _streamHandlers[gyroscopeStreamHandlerName] = gyroscopeStreamHandler

        let methodChannel = FlutterMethodChannel(
                name: "me.cendre.motion",
                binaryMessenger: registrar.messenger()
        )
        methodChannel.setMethodCallHandler { call, result in
            let streamHandler: MotionStreamHandler!;
            switch (call.method) {
            case "setUpdateInterval":
                streamHandler = _streamHandlers[gyroscopeStreamHandlerName]
                let updateInterval = call.arguments as! Int
                streamHandler.samplingPeriod = updateInterval
            case "isGyroscopeAvailable":
                result(_streamHandlers[gyroscopeStreamHandlerName]?.isAvailable() ?? false)
            default:
                return result(FlutterMethodNotImplemented)
            }
            result(nil)
        }

        _isCleanUp = false
    }

    static func _cleanUp() {
        _isCleanUp = true
        for channel in _eventChannels.values {
            channel.setStreamHandler(nil)
        }
        _eventChannels.removeAll()
        for handler in _streamHandlers.values {
            handler.onCancel(withArguments: nil)
        }
        _streamHandlers.removeAll()
    }
}

