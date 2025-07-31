//
//  MockAPIService.swift
//  NetworkService
//
//  Created by Karim Alweheshy on 31.07.25.
//

import Foundation
import Combine

class MockAPIService: ObservableObject {
    @Published var requests: [APIRequest] = []
    @Published var users: [UserData] = []
    @Published var isOnline: Bool = true
    @Published var networkStats: NetworkStats = NetworkStats(totalRequests: 0, successfulRequests: 0, failedRequests: 0, averageResponseTime: 0)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        generateSampleUsers()
        calculateStats()
    }
    
    // MARK: - Public API Methods
    
    func fetchUsers() -> AnyPublisher<APIResponse<[UserData]>, Error> {
        let request = APIRequest(endpoint: "/api/users", method: .GET)
        addRequest(request)
        
        return Future<APIResponse<[UserData]>, Error> { [weak self] promise in
            guard let self = self else { return }
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
                let shouldSucceed = self.isOnline && Double.random(in: 0...1) > 0.1 // 90% success rate
                
                if shouldSucceed {
                    let response = APIResponse(
                        data: self.users,
                        status: "success",
                        timestamp: Date()
                    )
                    self.completeRequest(request.id, success: true)
                    promise(.success(response))
                } else {
                    self.completeRequest(request.id, success: false)
                    promise(.failure(NetworkError.requestFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createUser(name: String, email: String, department: String) -> AnyPublisher<APIResponse<UserData>, Error> {
        let request = APIRequest(endpoint: "/api/users", method: .POST)
        addRequest(request)
        
        return Future<APIResponse<UserData>, Error> { [weak self] promise in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.3...1.5)) {
                let shouldSucceed = self.isOnline && Double.random(in: 0...1) > 0.05 // 95% success rate
                
                if shouldSucceed {
                    let newUser = UserData(
                        id: (self.users.map { $0.id }.max() ?? 0) + 1,
                        name: name,
                        email: email,
                        department: department,
                        status: .pending
                    )
                    
                    self.users.append(newUser)
                    
                    let response = APIResponse(
                        data: newUser,
                        status: "success",
                        timestamp: Date()
                    )
                    
                    self.completeRequest(request.id, success: true)
                    promise(.success(response))
                } else {
                    self.completeRequest(request.id, success: false)
                    promise(.failure(NetworkError.requestFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserStatus(userId: Int, status: UserStatus) -> AnyPublisher<APIResponse<UserData>, Error> {
        let request = APIRequest(endpoint: "/api/users/\(userId)", method: .PUT)
        addRequest(request)
        
        return Future<APIResponse<UserData>, Error> { [weak self] promise in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.2...1.0)) {
                let shouldSucceed = self.isOnline && Double.random(in: 0...1) > 0.08 // 92% success rate
                
                if shouldSucceed, let userIndex = self.users.firstIndex(where: { $0.id == userId }) {
                    self.users[userIndex] = UserData(
                        id: self.users[userIndex].id,
                        name: self.users[userIndex].name,
                        email: self.users[userIndex].email,
                        department: self.users[userIndex].department,
                        status: status
                    )
                    
                    let response = APIResponse(
                        data: self.users[userIndex],
                        status: "success",
                        timestamp: Date()
                    )
                    
                    self.completeRequest(request.id, success: true)
                    promise(.success(response))
                } else {
                    self.completeRequest(request.id, success: false)
                    promise(.failure(NetworkError.requestFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Network Control
    
    func toggleNetworkStatus() {
        isOnline.toggle()
    }
    
    func clearRequestHistory() {
        requests.removeAll()
        calculateStats()
    }
    
    // MARK: - Private Methods
    
    private func generateSampleUsers() {
        users = [
            UserData(id: 1, name: "Alice Johnson", email: "alice@company.com", department: "Engineering", status: .active),
            UserData(id: 2, name: "Bob Smith", email: "bob@company.com", department: "Design", status: .active),
            UserData(id: 3, name: "Carol Davis", email: "carol@company.com", department: "Marketing", status: .inactive),
            UserData(id: 4, name: "David Wilson", email: "david@company.com", department: "Sales", status: .pending),
            UserData(id: 5, name: "Eve Brown", email: "eve@company.com", department: "Engineering", status: .active),
        ]
    }
    
    private func addRequest(_ request: APIRequest) {
        DispatchQueue.main.async {
            self.requests.insert(request, at: 0) // Add to beginning for chronological order
            self.calculateStats()
        }
    }
    
    private func completeRequest(_ requestId: UUID, success: Bool) {
        DispatchQueue.main.async {
            if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                let originalRequest = self.requests[index]
                let responseTime = Date().timeIntervalSince(originalRequest.timestamp)
                
                let updatedRequest = APIRequest(endpoint: originalRequest.endpoint, method: originalRequest.method)
                // We can't modify the struct directly, so we'll replace it
                self.requests[index] = APIRequest(
                    id: originalRequest.id,
                    endpoint: originalRequest.endpoint,
                    method: originalRequest.method,
                    timestamp: originalRequest.timestamp,
                    status: success ? .success : .failed,
                    responseTime: responseTime
                )
                
                self.calculateStats()
            }
        }
    }
    
    private func calculateStats() {
        let totalRequests = requests.count
        let successfulRequests = requests.filter { $0.status == .success }.count
        let failedRequests = requests.filter { $0.status == .failed }.count
        
        let completedRequests = requests.filter { $0.responseTime != nil }
        let averageResponseTime = completedRequests.isEmpty ? 0 : 
            completedRequests.compactMap { $0.responseTime }.reduce(0, +) / Double(completedRequests.count)
        
        networkStats = NetworkStats(
            totalRequests: totalRequests,
            successfulRequests: successfulRequests,
            failedRequests: failedRequests,
            averageResponseTime: averageResponseTime
        )
    }
}

// Helper extension for APIRequest with mutable properties
private extension APIRequest {
    init(id: UUID, endpoint: String, method: HTTPMethod, timestamp: Date, status: RequestStatus, responseTime: TimeInterval?) {
        self.id = id
        self.endpoint = endpoint
        self.method = method
        self.timestamp = timestamp
        self.status = status
        self.responseTime = responseTime
    }
}

enum NetworkError: Error, LocalizedError {
    case requestFailed
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Request failed"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}