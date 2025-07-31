//
//  NetworkModels.swift
//  NetworkService
//
//  Created by Karim Alweheshy on 31.07.25.
//

import Foundation

struct APIResponse<T: Codable>: Codable {
    let data: T
    let status: String
    let timestamp: Date
}

struct UserData: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let department: String
    let status: UserStatus
}

enum UserStatus: String, Codable, CaseIterable {
    case active = "active"
    case inactive = "inactive"
    case pending = "pending"
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .pending: return "Pending"
        }
    }
    
    var color: String {
        switch self {
        case .active: return "green"
        case .inactive: return "red"
        case .pending: return "orange"
        }
    }
}

struct APIRequest {
    let id: UUID
    let endpoint: String
    let method: HTTPMethod
    let timestamp: Date
    let status: RequestStatus
    let responseTime: TimeInterval?
    
    init(endpoint: String, method: HTTPMethod) {
        self.id = UUID()
        self.endpoint = endpoint
        self.method = method
        self.timestamp = Date()
        self.status = .pending
        self.responseTime = nil
    }
}

enum HTTPMethod: String, CaseIterable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum RequestStatus: String {
    case pending = "pending"
    case success = "success"
    case failed = "failed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .success: return "Success"
        case .failed: return "Failed"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .success: return "green"
        case .failed: return "red"
        }
    }
}

struct NetworkStats {
    let totalRequests: Int
    let successfulRequests: Int
    let failedRequests: Int
    let averageResponseTime: TimeInterval
    
    var successRate: Double {
        guard totalRequests > 0 else { return 0 }
        return Double(successfulRequests) / Double(totalRequests) * 100
    }
}