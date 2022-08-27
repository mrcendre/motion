// Copyright 2022 Guillaume Cendre. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MTMotionPlugin.h"
#import <CoreMotion/CoreMotion.h>

static CMMotionManager *_motionManager;
static void _initMotionManager() {
  if (!_motionManager) {
    _motionManager = [[CMMotionManager alloc] init];
  }
}

static BOOL _isGyroscopeAvailable()
{
#ifdef __IPHONE_4_0
    _initMotionManager();
    BOOL gyroAvailable = _motionManager.gyroAvailable;
    return gyroAvailable;
#else
    return NO;
#endif

}


@interface MTMotionPlugin ()

@property (nonatomic, strong) FlutterMethodChannel* methodChannel;

@end

@implementation MTMotionPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  MTGyroscopeStreamHandler *gyroscopeStreamHandler =
      [[MTGyroscopeStreamHandler alloc] init];
  FlutterEventChannel *gyroscopeChannel = [FlutterEventChannel
      eventChannelWithName:@"me.cendre.motion/gyroscope"
           binaryMessenger:[registrar messenger]];
  [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];

  MTMotionPlugin* instance = [MTMotionPlugin new];
  instance.methodChannel = [FlutterMethodChannel 
      methodChannelWithName:@"me.cendre.motion" 
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:instance.methodChannel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    if ([@"setUpdateInterval" isEqualToString:call.method]) {
      NSUInteger updateInterval = [call.arguments unsignedIntegerValue];
      double sUpdateInterval = updateInterval / USEC_PER_SEC;

      _motionManager.gyroUpdateInterval = sUpdateInterval;

      result(@(YES));

      return;
    }
    
    if ([@"isGyroscopeAvailable" isEqualToString:call.method]) {
      BOOL available = _isGyroscopeAvailable();
      result(@(available));

      return;
    }

    result(FlutterMethodNotImplemented);
}



@end


static void sendTriplet(Float64 x, Float64 y, Float64 z,
                        FlutterEventSink sink) {
  NSMutableData *event = [NSMutableData dataWithCapacity:3 * sizeof(Float64)];
  [event appendBytes:&x length:sizeof(Float64)];
  [event appendBytes:&y length:sizeof(Float64)];
  [event appendBytes:&z length:sizeof(Float64)];
  sink([FlutterStandardTypedData typedDataWithFloat64:event]);
}

@implementation MTGyroscopeStreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments
                              eventSink:(FlutterEventSink)eventSink {
  _initMotionManager();
  [_motionManager
      startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
                  withHandler:^(CMGyroData *gyroData, NSError *error) {
                    CMRotationRate rotationRate = gyroData.rotationRate;
                    sendTriplet(rotationRate.x, rotationRate.y, rotationRate.z,
                                eventSink);
                  }];
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  [_motionManager stopGyroUpdates];
  return nil;
}

@end
