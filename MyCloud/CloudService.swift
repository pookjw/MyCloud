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
    let didReceiveNotificationStream = AsyncSubject<CKNotification>()
    
    override init() {
        super.init()
        
        let databases = [
//            container.publicCloudDatabase,
//            container.sharedCloudDatabase,
            container.privateCloudDatabase
        ]
        
        for database in databases {
            var subscriptions: [CKSubscription] = []
            
            do {
                let subscription = CKDatabaseSubscription(subscriptionID: "Test2")
                //            subscription.recordType = "Notes"
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                
                subscriptions.append(subscription)
            }
            
            do {
                let zoneID = CKRecordZone.ID(zoneName: "Notes", ownerName: CKCurrentUserDefaultName)
                let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: "Test3")
                
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                
                subscriptions.append(subscription)
            }
            
            do {
                let predicate = NSPredicate(value: true)
                let subscription = CKQuerySubscription(recordType: "Notes", predicate: predicate, subscriptionID: "Test4", options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
                
                let notificationInfo = CKSubscription.NotificationInfo()
                notificationInfo.shouldSendContentAvailable = true
                subscription.notificationInfo = notificationInfo
                
                subscriptions.append(subscription)
            }
            
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptions, subscriptionIDsToDelete: nil)
            
            operation.perSubscriptionSaveBlock = { subscriptionID, result in
                print("perSubscriptionSaveBlock", subscriptionID, result)
            }
            
            operation.perSubscriptionDeleteBlock = { subscriptionID, result in
                print("perSubscriptionDeleteBlock", subscriptionID, result)
            }
            
            operation.modifySubscriptionsResultBlock = { result in
                print("modifySubscriptionsResultBlock", result)
            }
            
            database.add(operation)
        }
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
        
        let result: (matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?) = try await withCheckedThrowingContinuation {
            continuation in
            // recordName을 Queryable하지 않아도 Fetch하는 방법이 있는 것 같음 Core Data 처럼
            let query = CKQuery(recordType: "Notes", predicate: NSPredicate(value: true))
            
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
    
    @discardableResult func saveNoteRecord(title: String, scope: CKDatabase.Scope, zone: CKRecordZone) async throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID)
        let record = CKRecord.init(recordType: "Notes", recordID: recordID)
        record.setObject(title as NSString, forKey: "title")
        
        let database = container.database(with: scope)
        try await database.save(record)
        return record
    }
    
    func foo() {
        let dbOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: nil)
        dbOperation.changeTokenUpdatedBlock = { token in
            print(token)
        }
        
        container.privateCloudDatabase.fetchAllRecordZones { zones, _ in
            let zoneOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zones!.map { $0.zoneID }, configurationsByRecordZoneID: nil)
            
            zoneOperation.recordWasChangedBlock = { recordID, result in
                print(result)
            }
            
            self.container.privateCloudDatabase.add(zoneOperation)
        }
        
//        dbOperation.recordZoneWithIDChangedBlock = { zoneID in
//            
//            let zoneOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: nil)
//            
//            zoneOperation.recordWasChangedBlock = { recordID, result in
//                print(result)
//            }
//            
//            self.container.privateCloudDatabase.add(zoneOperation)
//        }
        
        container.privateCloudDatabase.add(dbOperation)
    }
}
