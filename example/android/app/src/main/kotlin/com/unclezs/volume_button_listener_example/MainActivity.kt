package com.unclezs.volume_button_listener_example

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import com.unclezs.volume_button_listener.VolumeButtonListenerPlugin

class MainActivity : FlutterActivity() {
    
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // Get the plugin instance and handle volume keys
        val plugin = VolumeButtonListenerPlugin.getInstance()
        
        if (plugin != null) {
            // Check if this is a volume key
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                // Let the plugin handle it
                val handled = plugin.onActivityKeyDown(keyCode, event)
                if (handled) {
                    return true // Event consumed
                }
            }
        }
        
        // Call super for normal processing
        return super.onKeyDown(keyCode, event)
    }
}
