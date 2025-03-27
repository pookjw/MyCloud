//
//  HomeNavigationStackCoordinator.swift
//  MyCloud
//
//  Created by Jinwoo Kim on 3/27/25.
//

import Observation

@Observable
@MainActor
final class HomeNavigationStackCoordinator {
    var stack: [HomeNavigation] = [
        .zonesView
    ]
}
