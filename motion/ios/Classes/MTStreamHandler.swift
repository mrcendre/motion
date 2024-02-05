// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Flutter
import UIKit
import CoreMotion

var _motionManager: CMMotionManager!

public protocol MotionStreamHandler: FlutterStreamHandler {
    var samplingPeriod: Int { get set }

    func isAvailable() -> Bool
}

func _initMotionManager() {
    if (_motionManager == nil) {
        _motionManager = CMMotionManager()
        _motionManager.accelerometerUpdateInterval = 0.2
        _motionManager.deviceMotionUpdateInterval = 0.2
        _motionManager.gyroUpdateInterval = 0.2
        _motionManager.magnetometerUpdateInterval = 0.2
    }
}

func sendTriplet(x: Float64, y: Float64, z: Float64, sink: @escaping FlutterEventSink) {
    if _isCleanUp {
        return
    }
    // Even after [detachFromEngineForRegistrar] some events may still be received
    // and fired until fully detached.
    DispatchQueue.main.async {
        let triplet = [x, y, z]
        triplet.withUnsafeBufferPointer { buffer in
            sink(FlutterStandardTypedData.init(float64: Data(buffer: buffer)))
        }
    }
}

class MTGyroscopeStreamHandler: NSObject, MotionStreamHandler {

    var samplingPeriod = 200000 {
        didSet {
            _initMotionManager()
            _motionManager.gyroUpdateInterval = Double(samplingPeriod) * 0.000001
        }
    }

    func isAvailable() -> Bool {
        #if os(iOS) && !targetEnvironment(macCatalyst)
            _initMotionManager()
            let gyroAvailable = _motionManager.isGyroAvailable
            return gyroAvailable
        #else
            return false
        #endif
    }
 
    func onListen(
            withArguments arguments: Any?,
            eventSink sink: @escaping FlutterEventSink
    ) -> FlutterError? {
        _initMotionManager()
        _motionManager.startGyroUpdates(to: OperationQueue()) { data, error in
            if _isCleanUp {
                return
            }
            if (error != nil) {
                sink(FlutterError(
                        code: "UNAVAILABLE",
                        message: error!.localizedDescription,
                        details: nil
                ))
                return
            }
            let rotationRate = data!.rotationRate
            sendTriplet(x: rotationRate.x, y: rotationRate.y, z: rotationRate.z, sink: sink)
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _motionManager.stopGyroUpdates()
        return nil
    }

    func dealloc() {
        MTMotionPlugin._cleanUp()
    }
}
