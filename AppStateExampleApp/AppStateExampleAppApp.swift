//
//  AppStateExampleAppApp.swift
//  AppStateExampleApp
//
//  Created by amolonus on 27/12/2023.
//

import SwiftUI

@main
struct AppStateExampleAppApp: App {
    @StateObject var appStateManeger: AppStateManager = .init()
    var body: some Scene {
        WindowGroup {
            rootCoordinator
                .environmentObject(appStateManeger)
        }
    }
    
    @ViewBuilder
    private var rootCoordinator: some View {
        let viewModel: UICoordinatorViewModel = .init(appStateManager: appStateManeger)
        RootCoordinatorView(viewModel: viewModel)
    }
}
