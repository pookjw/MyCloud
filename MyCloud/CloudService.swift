//
//  CloudService.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import CloudKit
import Observation

@Observable
final class CloudService: NSObject {
    let container: CKContainer = .init(identifier: "iCloud.com.pookjw.BabiFud")
    
    override init() {
        super.init()
        
        let subscription = CKDatabaseSubscription(subscriptionID: "Test")
        subscription.recordType = "Notes"
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = ""
        
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: nil)
        
        operation.modifySubscriptionsResultBlock = { result in
            print(result)
        }
        
        container.privateCloudDatabase.add(operation)
    }
    
    func zones(for scope: CKDatabase.Scope) async throws -> [CKRecordZone] {
        let database = container.database(with: scope)
        return try await database.allRecordZones()
    }
    
    @discardableResult func createZone(for scope: CKDatabase.Scope, zoneName: String) async throws -> CKRecordZone {
        let database = container.database(with: scope)
        let zoneID = CKRecordZone.ID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)
        return try await database.save(zone)
    }
    
    func noteRecords(for scope: CKDatabase.Scope, zone: CKRecordZone) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        let database = container.database(with: scope)
        
        let recordID = CKRecord.ID(recordName: "Test", zoneID: zone.zoneID)
        let record = CKRecord(recordType: "CD_Notes", recordID: recordID)
        record.setObject("Test Name" as NSString, forKey: "name")
        try await database.save(record)
        
        
        let result: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?) = try await withCheckedThrowingContinuation {
            continuation in
            // recordName을 Queryable하지 않아도 Fetch하는 방법이 있는 것 같음 Core Data 처럼
            let query = CKQuery(recordType: "CD_Notes", predicate: NSPredicate(value: true))
            
            database.fetch(
                withQuery: query,
                inZoneWith: zone.zoneID,
                desiredKeys: nil,
                resultsLimit: 50
            ) { result in
                continuation.resume(with: result)
            }
        }
        
        return result.matchResults
    }
    
    @discardableResult func saveNoteRecord(title: String) async throws -> CKRecord {
        fatalError()
    }
}
