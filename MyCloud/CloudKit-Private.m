//
//  CloudKit-Private.m
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

#import "CloudKit-Private.h"
#import <objc/message.h>
#import <objc/runtime.h>

CKContainer * containerFromRecordZone(CKRecordZone *recordZone) {
    id _containerID;
    assert(object_getInstanceVariable(recordZone, "_containerID", (void **)&_containerID) != NULL);
    
    CKContainer *container = ((id (*)(id, SEL, id))objc_msgSend)([CKContainer alloc], sel_registerName("initWithContainerID:"), _containerID);
    return [container autorelease];
}
