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
import Settings
import Auth
import ToDoList
import ToDoDetail
import ToDoCreate
import Reminders
import Sharing

// MARK: - UserProfileView Bridge

struct UserProfileViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(UserProfileViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - AnalyticsView Bridge

struct AnalyticsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(AnalyticsViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - NetworkServiceView Bridge

struct NetworkServiceViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(NetworkServiceViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Navigation Helpers

struct NavigationDestination {
    enum Feature {
        case userProfile
        case analytics
        case networkService
        case settings
        case auth
        case toDoList
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
        case .settings:
            SettingsViewControllerRepresentable()
        case .auth:
            LoginViewControllerRepresentable()
        case .toDoList:
            ToDoListViewControllerRepresentable()
        }
    }
}

// MARK: - Settings Bridge

struct SettingsViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(SettingsViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Auth Bridge

struct LoginViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(LoginViewController())
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - To-Do Bridges

struct ToDoListViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        Inject.ViewControllerHost(ToDoListViewController())
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}