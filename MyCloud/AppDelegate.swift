//
//  AppDelegate.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import UserNotifications

#if os(macOS)

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    var cloudService: CloudService?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization { success, error in
            assert(error == nil)
            assert(success)
            
            Task { @MainActor in
                NSApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
        if let notificaton = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print(notificaton)
            cloudService?.didReceiveNotificationStream.yield(notificaton)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notificaton = CKNotification(fromRemoteNotificationDictionary: response.notification.request.content.userInfo) {
            print(notificaton)
            cloudService?.didReceiveNotificationStream.yield(notificaton)
        }
        completionHandler()
    }
}

#elseif os(iOS)

final class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    var cloudService: CloudService?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { success, error in
            assert(error == nil)
            assert(success)
            
            Task { @MainActor in
                application.registerForRemoteNotifications()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        if let notificaton = CKNotification(fromRemoteNotificationDictionary: userInfo) {
            print(notificaton)
            cloudService?.didReceiveNotificationStream.yield(notificaton)
        }
        
        return .noData
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notificaton = CKNotification(fromRemoteNotificationDictionary: response.notification.request.content.userInfo) {
            print(notificaton)
            cloudService?.didReceiveNotificationStream.yield(notificaton)
        }
        completionHandler()
    }
}

#endif
