//
//  HomeNavigation.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import CloudKit

enum HomeNavigation: Hashable {
    case cloudKitContainerView
    case zonesView
    case notesView(_ selectedScope: CKDatabase.Scope, _ zone: CKRecordZone)
}
