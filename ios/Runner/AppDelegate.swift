import UIKit
import Flutter
import FirebaseCore
import GoogleMaps
import flutter_local_notifications


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      if #available(iOS 12.0, *) {
        UNUserNotificationCenter.current().delegate = self
      }
    GMSServices.provideAPIKey("AIzaSyDdvZgn2cnPXchnUDNLIl1WA6HFPhwt8WI")
    GeneratedPluginRegistrant.register(with: self)
    // Ensures APNs registration runs early so FCM can resolve a device token.
    application.registerForRemoteNotifications()

    // super must be called first so the Flutter window/rootViewController is ready.
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Dynamic app icon channel
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(name: "app_icon", binaryMessenger: controller.binaryMessenger)
        .setMethodCallHandler { call, result in
          guard call.method == "changeIcon",
                let args = call.arguments as? [String: Any],
                let icon = args["icon"] as? String else {
            result(FlutterMethodNotImplemented)
            return
          }
          // Simulator does not support alternate icons — succeed silently.
          guard UIApplication.shared.supportsAlternateIcons else {
            result(nil)
            return
          }
          // nil resets to the primary icon (CustomerOpen = default).
          let iconName: String? = icon == "CustomerOpen" ? nil : icon
          UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
              result(FlutterError(code: "ICON_ERROR", message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
        }
    }

    return launched
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    AppsFlyerAttribution.shared()?.handleOpenUrl(url, options: options)
    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    AppsFlyerAttribution.shared()?.continueUserActivity(
      userActivity,
      restorationHandler: nil
    )
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
}
