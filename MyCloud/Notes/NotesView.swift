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
    
    @State private var isPresented = false
    @State private var text: String = ""
    
    init(scope: CKDatabase.Scope, zone: CKRecordZone) {
        self.scope = scope
        self.zone = zone
    }
    
    var body: some View {
        List(notes, id: \.recordID) { note in
            Text(note.object(forKey: "title") as? String ?? "nil")
        }
            .navigationTitle(zone.zoneID.zoneName)
            .toolbar {
                Button { 
                    text = ""
                    isPresented = true
                } label: { 
                    Label("Add Note", systemImage: "note.text.badge.plus")
                }
            }
            .alert("Title", isPresented: $isPresented) {
                TextField("", text: $text)
                Button("Done") {
                    Task {
                        let note = try! await cloudService.saveNoteRecord(title: text, scope: scope, zone: zone)
                        notes.append(note)
                    }
                }
            }
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
            }
            .task {
                for await notification in cloudService.didReceiveNotificationStream.stream(bufferingPolicy: .bufferingNewest(1)) {
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
                }
            }
    }
}
