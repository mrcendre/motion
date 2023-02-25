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

@implementation MTMotionPlugin

NSMutableDictionary<NSString *, FlutterEventChannel *> *_eventChannels;
NSMutableDictionary<NSString *, NSObject<FlutterStreamHandler> *> *_streamHandlers;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    
    //alloc channels names
    _eventChannels = [NSMutableDictionary dictionary];
    _streamHandlers = [NSMutableDictionary dictionary];
    
    MTMotionPlugin* instance = [MTMotionPlugin new];
    
    NSString* gyroscopeStreamHandlerName = @"me.cendre.motion/gyroscope";
    MTGyroscopeStreamHandler* gyroscopeStreamHandler = [MTGyroscopeStreamHandler new];
    [_streamHandlers setObject:gyroscopeStreamHandler forKey:gyroscopeStreamHandlerName];
    
    FlutterEventChannel* gyroscopeChannel = [FlutterEventChannel eventChannelWithName:gyroscopeStreamHandlerName
                                                                      binaryMessenger:[registrar messenger]];
    [gyroscopeChannel setStreamHandler:gyroscopeStreamHandler];
    [_eventChannels setObject:gyroscopeChannel forKey:gyroscopeStreamHandlerName];
    
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName:@"me.cendre.motion"
                                                                      binaryMessenger:[registrar messenger]];
    
    [registrar addMethodCallDelegate:instance channel:methodChannel];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar{
    _cleanUp();
}

static void _cleanUp(){
    for (FlutterEventChannel *channel in _eventChannels.allValues) {
        [channel setStreamHandler:nil];
    }
    [_eventChannels removeAllObjects];
    for (NSObject<FlutterStreamHandler> *handler in _streamHandlers.allValues) {
        [handler onCancelWithArguments:nil];
    }
    [_streamHandlers removeAllObjects];
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
    //even if we removed all with [detachFromEngineForRegistrar] we can still receive and fire some events
    //from sensors until detaching.
    @try {
        NSMutableData *event = [NSMutableData dataWithCapacity:3 * sizeof(Float64)];
        [event appendBytes:&x length:sizeof(Float64)];
        [event appendBytes:&y length:sizeof(Float64)];
        [event appendBytes:&z length:sizeof(Float64)];
        sink([FlutterStandardTypedData typedDataWithFloat64:event]);
    }
    @catch (NSException * e) {
        NSLog(@"Error: %@ %@", e, [e userInfo]);
    }
    @finally {}
}

@implementation MTGyroscopeStreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments
                              eventSink:(FlutterEventSink)eventSink {
    
    _initMotionManager();
    
    [_motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
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

- (void)dealloc
{
    _cleanUp();
}

@end
