//
//  ZonesView.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import CloudKit

struct ZonesView: View {
    @Environment(CloudService.self) private var cloudService
    @State private var selectedScope: CKDatabase.Scope = .private
    @State private var zones: [CKRecordZone] = []
    @State private var isPresented = false
    @State private var text: String = ""
    
    var body: some View {
        List(zones, id: \.zoneID) { zone in
            NavigationLink(zone.zoneID.zoneName, value: HomeNavigation.notesView(selectedScope, zone))
        }
        .toolbar {
            containerMenu
            addButton
        }
        .alert("Zone Name", isPresented: $isPresented) {
            TextField("", text: $text)
            
            Button("OK") {
                Task {
                    try! await cloudService.createZone(for: selectedScope, zoneName: text)
                }
            }
        }
        .task {
            zones = try! await cloudService.zones(for: selectedScope)
        }
    }
    
    @ViewBuilder private var containerMenu: some View {
        Menu("Container", systemImage: "square.stack.fill") {
            ForEach(CKDatabase.Scope.allCases, id: \.rawValue) { scope in
                Toggle(
                    scope.string,
                    isOn: Binding(
                        get: {
                            selectedScope == scope
                        },
                        set: { newValue in
                            selectedScope = scope
                        }
                    )
                )
            }
        }
    }
    
    @ViewBuilder private var addButton: some View {
        Button {
            text = ""
            isPresented = true
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}

#Preview {
    ZonesView()
}
