//
//  NotesView.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import SwiftUI
import CloudKit

struct NotesView: View {
    @Environment(CloudService.self) private var cloudService
    private let scope: CKDatabase.Scope
    private let zone: CKRecordZone
    @State private var notes: [CKRecord] = []
    
    init(scope: CKDatabase.Scope, zone: CKRecordZone) {
        self.scope = scope
        self.zone = zone
    }
    
    var body: some View {
        Text(zone.zoneID.zoneName)
            .task {
                let results = try! await cloudService.noteRecords(for: scope, zone: zone)
                let notes = results
                    .compactMap { (id, result) in
                        switch result {
                        case .success(let record):
                            return record
                        case .failure(let error):
                            print(error)
                            return nil
                        }
                    }
                
                self.notes = notes
                
                print(notes)
            }
    }
}
