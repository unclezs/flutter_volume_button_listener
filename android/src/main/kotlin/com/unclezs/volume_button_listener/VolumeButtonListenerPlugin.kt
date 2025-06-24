package com.unclezs.volume_button_listener

import android.app.Activity
import android.util.Log
import android.view.KeyEvent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VolumeButtonListenerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var isListening = false
    private var showVolumeUI = true

    companion object {
        private const val TAG = "VolumeButtonListener"
        private var instance: VolumeButtonListenerPlugin? = null
        
        fun getInstance(): VolumeButtonListenerPlugin? {
            return instance
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "volume_button_listener")
        channel.setMethodCallHandler(this)
        instance = this
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method call: ${call.method}")
        when (call.method) {
            "initialize" -> {
                Log.d(TAG, "Initializing plugin")
                result.success(null)
            }
            "setShowVolumeUI" -> {
                showVolumeUI = call.argument<Boolean>("show") ?: true
                Log.d(TAG, "setShowVolumeUI: $showVolumeUI")
                result.success(null)
            }
            "startListening" -> {
                isListening = true
                Log.d(TAG, "startListening: $isListening")
                result.success(null)
            }
            "stopListening" -> {
                isListening = false
                Log.d(TAG, "stopListening: $isListening")
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        instance = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        
        // Try to override the activity's onKeyDown method using reflection
        try {
            val activityClass = activity?.javaClass
            if (activityClass != null) {
                Log.d(TAG, "Activity class: $activityClass")
                // We'll handle key events in a different way
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to setup activity key handling", e)
        }
        
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        Log.d(TAG, "Detached from activity for config changes")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
    
    // This method will be called by the activity
    fun onActivityKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (isListening && event != null && event.action == KeyEvent.ACTION_DOWN) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP -> {
                    channel.invokeMethod("onVolumeButtonPressed", mapOf(
                        "type" to "volumeUp",
                        "buttonKey" to keyCode,
                        "buttonName" to "Volume Up"
                    ))
                    return !showVolumeUI // 如果showVolumeUI为false，返回true消费事件
                }
                KeyEvent.KEYCODE_VOLUME_DOWN -> {
                    channel.invokeMethod("onVolumeButtonPressed", mapOf(
                        "type" to "volumeDown",
                        "buttonKey" to keyCode,
                        "buttonName" to "Volume Down"
                    ))
                    return !showVolumeUI // 如果showVolumeUI为false，返回true消费事件
                }
            }
        }
        return false
    }
} 