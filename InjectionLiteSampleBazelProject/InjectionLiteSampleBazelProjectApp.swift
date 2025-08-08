//
//  InjectionLiteSampleBazelProjectApp.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 30.07.25.
//

import SwiftUI
import AppCore
import Navigation
import Auth
import Settings
import AppCore





@main
struct InjectionLiteSampleBazelProjectApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var window: UIWindow?
    @State private var navigator: Navigator = RootNavigator()

    init() {
        // Register global services for DI
        ServiceLocator.shared.register(MockAuthService() as AuthService)
        ServiceLocator.shared.register(InMemoryFeatureFlagsService(flags: [
            "dark_mode": true,
            "exp_charts": false,
        ]) as FeatureFlagsService)
        ServiceLocator.shared.register(InMemoryToDoRepository() as ToDoRepository)
    }

    var body: some View {
        ContentView()
            .background(WindowAccessor(window: $window))
            .onAppear {
                if let window { navigator.start(in: window) }
            }
    }
}

private struct WindowAccessor: UIViewRepresentable {
    @Binding var window: UIWindow?
    func makeUIView(context: Context) -> UIView { AccessorView(window: $window) }
    func updateUIView(_ uiView: UIView, context: Context) {}
    private final class AccessorView: UIView {
        @Binding var windowRef: UIWindow?
        init(window: Binding<UIWindow?>) { _windowRef = window; super.init(frame: .zero) }
        required init?(coder: NSCoder) { fatalError() }
        override func didMoveToWindow() { super.didMoveToWindow(); windowRef = window }
    }
}
