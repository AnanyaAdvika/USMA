import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ── Firebase initialisation ───────────────────────────────────────────
    FirebaseApp.configure()

    // ── Push notification delegate ────────────────────────────────────────
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    // Request authorisation for alerts, badges, and sounds
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, error in
      if let error = error {
        print("USMA: notification permission error: \(error.localizedDescription)")
      } else {
        print("USMA: notification permission granted: \(granted)")
      }
    }

    // Register for remote notifications so APNs token is available
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── FlutterImplicitEngineDelegate ─────────────────────────────────────
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // ── APNs token → FCM ──────────────────────────────────────────────────
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("USMA: APNs registration failed: \(error.localizedDescription)")
  }
}

// ── UNUserNotificationCenterDelegate ────────────────────────────────────────
// Called when a notification is delivered while the app is in the foreground.
extension AppDelegate: UNUserNotificationCenterDelegate {
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler:
      @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show banner + badge + sound even when the app is in the foreground
    completionHandler([.banner, .badge, .sound])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}

// ── MessagingDelegate ────────────────────────────────────────────────────────
// Receives the FCM registration token; forward it to the Flutter layer via
// firebase_messaging plugin which is already registered in GeneratedPluginRegistrant.
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("USMA: FCM token: \(fcmToken ?? "nil")")
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}