//
//  UIKitBridges.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 31.07.25.
//

import SwiftUI
import UIKit
import UserProfile
import DataAnalytics
import Inject
import NetworkService

// MARK: - UserProfileView Bridge

struct UserProfileViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = Inject.ViewControllerHost(UserProfileViewController())
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed for this implementation
    }
}

// MARK: - AnalyticsView Bridge

struct AnalyticsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = Inject.ViewControllerHost(AnalyticsViewController())
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed for this implementation
    }
}

// MARK: - NetworkServiceView Bridge

struct NetworkServiceViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let viewController = Inject.ViewControllerHost(NetworkServiceViewController())
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed for this implementation
    }
}

// MARK: - Navigation Helpers

struct NavigationDestination {
    enum Feature {
        case userProfile
        case analytics
        case networkService
    }
    
    @ViewBuilder
    static func view(for feature: Feature) -> some View {
        switch feature {
        case .userProfile:
            UserProfileViewControllerRepresentable()
        case .analytics:
            AnalyticsViewControllerRepresentable()
        case .networkService:
            NetworkServiceViewControllerRepresentable()
        }
    }
}