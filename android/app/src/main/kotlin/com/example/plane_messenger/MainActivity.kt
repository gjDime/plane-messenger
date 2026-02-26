package com.example.plane_messenger

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.location.LocationManager
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var eventSink: EventChannel.EventSink? = null
    private var serviceReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // One-shot calls: Wi-Fi status check + opening system settings screens.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.plane.messenger/system",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isWifiEnabled" -> {
                    @Suppress("DEPRECATION")
                    val wm = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager
                    result.success(wm.isWifiEnabled)
                }
                "openBluetoothSettings" -> {
                    startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
                    result.success(null)
                }
                "openLocationSettings" -> {
                    startActivity(Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS))
                    result.success(null)
                }
                "openWifiSettings" -> {
                    startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Continuous stream: fires whenever Bluetooth, Wi-Fi, or Location is
        // turned off while the app is running.
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.plane.messenger/service_events",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                registerServiceReceivers()
            }

            override fun onCancel(arguments: Any?) {
                unregisterServiceReceivers()
                eventSink = null
            }
        })
    }

    private fun registerServiceReceivers() {
        val filter = IntentFilter().apply {
            addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            addAction(WifiManager.WIFI_STATE_CHANGED_ACTION)
            addAction(LocationManager.PROVIDERS_CHANGED_ACTION)
        }

        serviceReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothAdapter.ACTION_STATE_CHANGED -> {
                        val state = intent.getIntExtra(
                            BluetoothAdapter.EXTRA_STATE,
                            BluetoothAdapter.ERROR,
                        )
                        if (state == BluetoothAdapter.STATE_OFF) {
                            eventSink?.success("bluetooth_off")
                        }
                    }

                    WifiManager.WIFI_STATE_CHANGED_ACTION -> {
                        val state = intent.getIntExtra(
                            WifiManager.EXTRA_WIFI_STATE,
                            WifiManager.WIFI_STATE_UNKNOWN,
                        )
                        if (state == WifiManager.WIFI_STATE_DISABLED) {
                            eventSink?.success("wifi_off")
                        }
                    }

                    LocationManager.PROVIDERS_CHANGED_ACTION -> {
                        val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
                        val anyEnabled =
                            lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        if (!anyEnabled) {
                            eventSink?.success("location_off")
                        }
                    }
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(serviceReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(serviceReceiver, filter)
        }
    }

    private fun unregisterServiceReceivers() {
        serviceReceiver?.let { receiver ->
            try {
                unregisterReceiver(receiver)
            } catch (_: IllegalArgumentException) {
                // Receiver was never registered — ignore.
            }
        }
        serviceReceiver = null
    }

    override fun onDestroy() {
        unregisterServiceReceivers()
        super.onDestroy()
    }
}
