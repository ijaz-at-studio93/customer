package com.anantax.scuts

import android.content.ComponentName
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val pkg = "com.anantax.scuts"
    private val aliases = mapOf(
        "CustomerOpen"   to "$pkg.MainActivityCustomerOpen",
        "CustomerBook"   to "$pkg.MainActivityCustomerBook",
        "Customer3Weeks" to "$pkg.MainActivityCustomer3Weeks",
        "Customer4Weeks" to "$pkg.MainActivityCustomer4Weeks",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app_icon")
            .setMethodCallHandler { call, result ->
                if (call.method == "changeIcon") {
                    val name = call.argument<String>("icon") ?: "CustomerOpen"
                    switchAlias(name)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun switchAlias(target: String) {
        val targetAlias = aliases[target] ?: aliases["CustomerOpen"]!!

        // Enable the new alias first so the launcher always has an active entry.
        packageManager.setComponentEnabledSetting(
            ComponentName(pkg, targetAlias),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        // Disable all other aliases after a short delay. Without the delay,
        // disabling the currently-active alias can cause the system to kill
        // the process even with DONT_KILL_APP on some devices.
        Handler(Looper.getMainLooper()).postDelayed({
            aliases.values.filter { it != targetAlias }.forEach { alias ->
                packageManager.setComponentEnabledSetting(
                    ComponentName(pkg, alias),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
        }, 1000)
    }
}
