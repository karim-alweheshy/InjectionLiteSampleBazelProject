//
//  ServiceLocator.swift
//  AppCore
//
//  A tiny DI container for demo purposes.
//

import Foundation

public final class ServiceLocator {
    public static let shared = ServiceLocator()

    private var services: [ObjectIdentifier: Any] = [:]
    private let lock = NSLock()

    public init() {}

    public func register<Service>(_ service: Service) {
        let key = ObjectIdentifier(Service.self)
        lock.lock(); defer { lock.unlock() }
        services[key] = service
    }

    public func resolve<Service>() -> Service {
        let key = ObjectIdentifier(Service.self)
        lock.lock(); defer { lock.unlock() }
        guard let service = services[key] as? Service else {
            fatalError("Service of type \(Service.self) is not registered")
        }
        return service
    }
}


