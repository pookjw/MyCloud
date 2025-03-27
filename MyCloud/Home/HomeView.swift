//
//  HomeView.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import CloudKit

struct HomeView: View {
    @Environment(CloudService.self) private var cloudService
    @State private var coordinator: HomeNavigationStackCoordinator = .init()
    
    var body: some View {
        NavigationStack(path: $coordinator.stack) { 
            ZonesView()
                .navigationDestination(for: HomeNavigation.self) { navigation in
                    switch navigation {
                    case .cloudKitContainerView:
                        CloudKitContainerView()
                    case .zonesView:
                        ZonesView()
                    case .notesView(let scope, let zone):
                        NotesView(scope: scope, zone: zone)
                    }
                }
        }
        .environment(coordinator)
    }
}

#Preview {
    HomeView()
}
