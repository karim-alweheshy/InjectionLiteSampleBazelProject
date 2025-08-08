//
//  Navigator.swift
//  Navigation
//

import UIKit

public enum AppRoute {
    case userProfile
    case analytics
    case network
    case settings
    case auth
}

public protocol Navigator {
    func start(in window: UIWindow)
    func navigate(to route: AppRoute)
}

public final class RootNavigator: Navigator {
    private weak var window: UIWindow?
    private var rootNavigationController: UINavigationController?

    public init() {}

    public func start(in window: UIWindow) {
        self.window = window
        let root = UIViewController()
        root.view.backgroundColor = .systemBackground
        root.title = "Home"
        let nav = UINavigationController(rootViewController: root)
        rootNavigationController = nav
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    public func navigate(to route: AppRoute) {
        switch route {
        case .userProfile:
            push(viewController: makeViewController(className: "UserProfile.UserProfileViewController"))
        case .analytics:
            push(viewController: makeViewController(className: "DataAnalytics.AnalyticsViewController"))
        case .network:
            push(viewController: makeViewController(className: "NetworkService.NetworkServiceViewController"))
        case .settings:
            push(viewController: makeViewController(className: "Settings.SettingsViewController"))
        case .auth:
            push(viewController: makeViewController(className: "Auth.LoginViewController"))
        }
    }

    private func push(viewController: UIViewController?) {
        guard let vc = viewController else { return }
        rootNavigationController?.pushViewController(vc, animated: true)
    }

    private func makeViewController(className: String) -> UIViewController? {
        guard let cls = NSClassFromString(className) as? UIViewController.Type else { return nil }
        return cls.init()
    }
}


