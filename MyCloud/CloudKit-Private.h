//
//  CloudKit-Private.h
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

CK_EXTERN NSNotificationName const CKAccountChangedNotificationName(void);
CK_EXTERN NSString * CKStringFromAccountStatus(CKAccountStatus);

CK_EXTERN CKContainer * containerFromRecordZone(CKRecordZone *recordZone);

@interface CKRecord (Private)
- (BOOL)containsIndexedKeys;
@end

NS_ASSUME_NONNULL_END
