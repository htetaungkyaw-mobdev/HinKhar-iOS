//
//  HinKhar_Restaurants_DirectoryApp.swift
//  HinKhar Restaurants Directory
//
//  Created by Htet Aung Kyaw on 27/11/2025.
//

import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UserNotifications

extension Notification.Name {
    static let firebaseMessagingTokenDidChange = Notification.Name("firebaseMessagingTokenDidChange")
    static let firebaseNotificationReceived = Notification.Name("firebaseNotificationReceived")
}

final class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        Messaging.messaging().delegate = self
        Messaging.messaging().register { _ in }

        // Submit the last known token before authentication; Firebase will also deliver a refreshed token below.
        Task {
            await DeviceTokenRegistrationService.shared.registerStoredToken(isSignedIn: false)
        }

        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else {
                return
            }

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else {
            return
        }

        print("fcmToken = \(fcmToken)")
        KeychainManager.shared.save(fcmToken, forKey: KeychainKeys.fcmToken)
        NotificationCenter.default.post(
            name: .firebaseMessagingTokenDidChange,
            object: fcmToken
        )

        Task {
            let isSignedIn = KeychainManager.shared.get(KeychainKeys.userToken) != nil
            await DeviceTokenRegistrationService.shared.register(
                fcmToken: fcmToken,
                isSignedIn: isSignedIn
            )
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        NotificationCenter.default.post(
            name: .firebaseNotificationReceived,
            object: notification.request.content.userInfo
        )
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        NotificationCenter.default.post(
            name: .firebaseNotificationReceived,
            object: response.notification.request.content.userInfo
        )
        completionHandler()
    }
}

@main
struct HinKhar_Restaurants_DirectoryApp: App {
    @StateObject private var auth = AuthViewModel()

    @State private var isShowedWelcome = KeychainManager.shared.get(KeychainKeys.isShowedWelcome) ?? "no"

    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environment(\.locale, Locale(identifier: selectedLanguageCode))
                .onAppear {
                    sleep(2)
                }
        }
    }
}
