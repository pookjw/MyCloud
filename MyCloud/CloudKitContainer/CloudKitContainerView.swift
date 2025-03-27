//
//  CloudKitContainerView.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import CloudKit

struct CloudKitContainerView: View {
    @Environment(CloudService.self) private var cloudService
    @State private var accountStatus: CKAccountStatus? = nil
    
    var body: some View {
        Form {
            Label {
                Text(String(describing: cloudService.container.sharedCloudDatabase))
            } icon: {
                Text("Shared")
            }
            
            Label {
                Text(String(describing: cloudService.container.publicCloudDatabase))
            } icon: {
                Text("Public")
            }
            
            Label {
                Text(String(describing: cloudService.container.privateCloudDatabase))
            } icon: {
                Text("Private")
            }
            
            Label {
                Text(cloudService.container.containerIdentifier ?? "(nil)")
            } icon: {
                Text("Container Identifier")
            }
            
            Label {
                Text({
                    if let accountStatus {
                        return CKStringFromAccountStatus(accountStatus)
                    } else {
                        return "(null)"
                    }
                }())
            } icon: {
                Text("Account Status")
            }
            
            Label { 
                Text(CKCurrentUserDefaultName)
            } icon: { 
                Text("Current User Default Name")
            }

        }
        .task {
            accountStatus = try! await cloudService.container.accountStatus()
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: CKAccountChangedNotificationName(), object: nil) {
                accountStatus = try! await cloudService.container.accountStatus()
            }
        }
    }
}

#Preview {
    CloudKitContainerView()
}
