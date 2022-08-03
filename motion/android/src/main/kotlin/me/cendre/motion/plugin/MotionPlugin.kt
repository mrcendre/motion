package me.cendre.motion.plugin

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** MotionPlugin  */
class MotionPlugin : FlutterPlugin {
    private lateinit var gyroscopeChannel: EventChannel

    private lateinit var methodChannel: MethodChannel

    private lateinit var gyroScopeStreamHandler: StreamHandlerImpl

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        setupEventChannels(binding.applicationContext, binding.binaryMessenger, DEFAULT_UPDATE_INTERVAL)
        setupMethodChannel(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        teardownEventChannels()
        teardownMethodChannel()
    }

    private fun setupEventChannels(context: Context, messenger: BinaryMessenger, updateInterval: Int) {
        val sensorsManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        gyroscopeChannel = EventChannel(messenger, GYROSCOPE_CHANNEL_NAME)
        gyroScopeStreamHandler = StreamHandlerImpl(
                sensorsManager,
                Sensor.TYPE_GYROSCOPE,
                updateInterval
        )
        gyroscopeChannel.setStreamHandler(gyroScopeStreamHandler)
    }

    private fun teardownEventChannels() {
        gyroscopeChannel.setStreamHandler(null)
        gyroScopeStreamHandler.onCancel(null)
    }

    private fun setupMethodChannel(context: Context, messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        methodChannel.setMethodCallHandler {
            call, result ->

            if (call.method == "setUpdateInterval") {
                teardownEventChannels()
                setupEventChannels(context, messenger, call.arguments as Int)
            }

        }
    }

    private fun teardownMethodChannel() {
        methodChannel.setMethodCallHandler(null)
    }

    companion object {
        private const val GYROSCOPE_CHANNEL_NAME = "me.cendre.motion/gyroscope"
        private const val METHOD_CHANNEL_NAME = "me.cendre.motion"
        private const val DEFAULT_UPDATE_INTERVAL = SensorManager.SENSOR_DELAY_NORMAL
    }
}
