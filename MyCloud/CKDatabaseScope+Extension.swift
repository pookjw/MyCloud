//
//  CKDatabaseScope+Extension.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import CloudKit

extension CKDatabase.Scope {
    static let allCases: [CKDatabase.Scope] = [
        .shared, .public, .private
    ]
    
    var string: String {
        switch self {
        case .public:
            "Public"
        case .private:
            "Private"
        case .shared:
            "Shared"
        @unknown default:
            fatalError()
        }
    }
}
