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
        
    }
}

#elseif os(iOS)

#endif
