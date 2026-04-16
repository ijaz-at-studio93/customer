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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
