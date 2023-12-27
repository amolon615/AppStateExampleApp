//
//  ContentView.swift
//  AppStateExampleApp
//
//  Created by amolonus on 27/12/2023.
//


import SwiftUI

enum AppState: Int, CaseIterable {
    case onboarding = 0
    case paywall = 1
    case app = 2
}

enum PaymentStatus: Int, CaseIterable {
    case payed = 0
    case expired = 1
}

class AppStateManager: ObservableObject {
    var appState: AppState = .onboarding {
        didSet {
            saveAppState()
            objectWillChange.send()
        }
    }
    
    var paymentStatus: PaymentStatus = .expired {
        didSet {
            savePaymentStatus()
            objectWillChange.send()
        }
    }
    
    var isOnboarded: Bool = false {
        didSet {
            saveOnboardingStatus()
            objectWillChange.send()
        }
    }
    
    func resetOnboarding() {
        appState = .onboarding
        saveOnboardingStatus()
    }
    
    func finishOnboarding() {
        switch paymentStatus {
        case .payed:
            appState = .app
        case .expired:
            appState = .paywall
        }
        saveOnboardingStatus()
    }
    
    func processPayment() {
        paymentStatus = .payed
        appState = .app
        saveAppState()
        savePaymentStatus()
    }
    
    func expirePayment() {
        paymentStatus = .expired
        appState = .paywall
        saveAppState()
        savePaymentStatus()
        
    }
    
    init() {
        loadOnboardingStatus()
        loadPaymentStatus()
        loadAppState()
        
    }
    
    private func loadAppState() {
        if let savedAppState = UserDefaults.standard.value(forKey: "appState") as? Int,
           let appState = AppState(rawValue: savedAppState) {
            self.appState = appState
        }
    }
    
    private func loadPaymentStatus() {
        if let savedPaymentStatus = UserDefaults.standard.value(forKey: "paymentStatus") as? Int,
           let paymentStatus = PaymentStatus(rawValue: savedPaymentStatus) {
            self.paymentStatus = paymentStatus
        }
    }
    
    
    private func loadOnboardingStatus() {
        isOnboarded = UserDefaults.standard.value(forKey: "isOnboarded") as? Bool ?? true
    }
    
    private func saveAppState() {
        UserDefaults.standard.setValue(appState.rawValue, forKey: "appState")
    }
    
    private func savePaymentStatus() {
        UserDefaults.standard.setValue(paymentStatus.rawValue, forKey: "paymentStatus")
    }
    
    private func saveOnboardingStatus() {
        UserDefaults.standard.setValue(isOnboarded, forKey: "isOnboarded")
    }

}
protocol CoordinatorViewModel: ObservableObject {
    var appStateManager: AppStateManager { get }
    var appState: AppState { get }
}

class UICoordinatorViewModel: CoordinatorViewModel {
    var appStateManager: AppStateManager
    
    var appState: AppState {
        appStateManager.appState
    }
    
    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }
}

protocol OnboardingViewModel: ObservableObject {
    var appStateManager: AppStateManager { get }
    
    func finishOnboarding()
}

class UIOnboardingViewModel: OnboardingViewModel {
    var appStateManager: AppStateManager
    
    
    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }
    
    func finishOnboarding() {
        appStateManager.finishOnboarding()
    }
}

protocol PaywallViewModel: ObservableObject {
    var appStateManager: AppStateManager { get }
    
    func processPayment()
}

class UIPaywallViewModel: PaywallViewModel {
    var appStateManager: AppStateManager
    
    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }
    
    func processPayment() {
        appStateManager.processPayment()
    }
}

protocol AppViewModel: ObservableObject {
    var appStateManager: AppStateManager { get }
    
    func reseOnboarding()
    func expirePayment()
}

class UIAppViewViewModel: ObservableObject {
    var appStateManager: AppStateManager
    
    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
    }
    
    func reseOnboarding() {
        appStateManager.resetOnboarding()
    }
    
    func expirePayment() {
        appStateManager.expirePayment()
    }
}

struct RootCoordinatorView: View {
    @EnvironmentObject var stateManager: AppStateManager
    @StateObject var viewModel: UICoordinatorViewModel
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.appState {
                case .onboarding:
                    onboardingView
                case .paywall:
                    paywallView
                case .app:
                    appView
                }
            }
        }
    }
    
    @ViewBuilder
    private var onboardingView: some View {
        let viewModel: UIOnboardingViewModel = .init(appStateManager: stateManager)
        OnboardingView(viewModel: viewModel)
    }
    
    @ViewBuilder
    private var paywallView: some View {
        let viewModel: UIPaywallViewModel = .init(appStateManager: stateManager)
        PaywallView(viewModel: viewModel)
    }
    
    @ViewBuilder
    private var appView: some View {
        let viewModel: UIAppViewViewModel = .init(appStateManager: stateManager)
        AppView(viewModel: viewModel)
    }
}

struct OnboardingView: View {
    @StateObject var viewModel: UIOnboardingViewModel
    var body: some View {
        VStack {
            Text("OnboardingView")
            Button {
                viewModel.finishOnboarding()
            } label: {
                Text("Finish Onboarding")
            }
        }
    }
}

struct PaywallView: View {
    @StateObject var viewModel: UIPaywallViewModel
    var body: some View {
        VStack {
            Text("Paywall")
            Button {
                viewModel.processPayment()
            } label: {
                Text("Pay")
            }
        }
    }
}

struct AppView: View {
    @StateObject var viewModel: UIAppViewViewModel
    var body: some View {
        VStack {
            Text("AppView")
            Button {
                viewModel.reseOnboarding()
            } label: {
                Text("Reset Onboarding")
            }
            
            Button {
                viewModel.expirePayment()
            } label: {
                Text("Expire Payment")
            }
        }
    }
}

