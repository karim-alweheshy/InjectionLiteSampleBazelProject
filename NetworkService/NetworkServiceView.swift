//
//  NetworkServiceView.swift
//  NetworkService
//
//  Created by Karim Alweheshy on 31.07.25.
//

import SwiftUI
import Combine
import Inject
import DataAnalytics

public struct NetworkServiceView: View {
    @StateObject private var apiService = MockAPIService()
    @State private var showingAddUser = false
    @State private var selectedUser: UserData?
    @State private var cancellables = Set<AnyCancellable>()
    @ObserveInjection var inject
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Network Status
                    networkStatusSection
                    
                    // Stats Overview
                    statsSection
                    
                    // Users List
                    usersSection
                    
                    // Request History
                    requestHistorySection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Network Service")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAddUser) {
            AddUserView(apiService: apiService)
        }
        .enableInjection()
    }
    
    private var networkStatusSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Network Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack {
                    Circle()
                        .fill(apiService.isOnline ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(apiService.isOnline ? "Online" : "Offline")
                        .font(.subheadline)
                        .foregroundColor(apiService.isOnline ? .green : .red)
                }
            }
            
            Spacer()
            
            Button(action: {
                apiService.toggleNetworkStatus()
            }) {
                Text(apiService.isOnline ? "Go Offline" : "Go Online")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(apiService.isOnline ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .foregroundColor(apiService.isOnline ? .red : .green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Total Requests",
                    value: "\(apiService.networkStats.totalRequests)",
                    color: .blue
                )
                
                StatCard(
                    title: "Success Rate",
                    value: String(format: "%.1f%%", apiService.networkStats.successRate),
                    color: .green
                )
                
                StatCard(
                    title: "Failed Requests",
                    value: "\(apiService.networkStats.failedRequests)",
                    color: .red
                )
                
                StatCard(
                    title: "Avg Response",
                    value: String(format: "%.2fs", apiService.networkStats.averageResponseTime),
                    color: .orange
                )
            }
        }
    }
    
    private var usersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Users")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Refresh") {
                    fetchUsers()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(apiService.users) { user in
                    UserRow(user: user) { newStatus in
                        updateUserStatus(user: user, status: newStatus)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var requestHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Requests")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Clear") {
                    apiService.clearRequestHistory()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            if apiService.requests.isEmpty {
                Text("No requests yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 6) {
                    ForEach(Array(apiService.requests.prefix(5).enumerated()), id: \.element.id) { index, request in
                        RequestRow(request: request)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                fetchUsers()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Fetch Users")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Button(action: {
                showingAddUser = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Add New User")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchUsers() {
        apiService.fetchUsers()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching users: \(error)")
                    }
                },
                receiveValue: { response in
                    // Users are automatically updated in the service
                    print("Fetched \(response.data.count) users")
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateUserStatus(user: UserData, status: UserStatus) {
        apiService.updateUserStatus(userId: user.id, status: status)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error updating user: \(error)")
                    }
                },
                receiveValue: { response in
                    print("Updated user: \(response.data.name)")
                }
            )
            .store(in: &cancellables)
    }
}

struct UserRow: View {
    let user: UserData
    let onStatusChange: (UserStatus) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(user.department)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                ForEach(UserStatus.allCases, id: \.self) { status in
                    Button(status.displayName) {
                        onStatusChange(status)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForStatus(user.status))
                        .frame(width: 8, height: 8)
                    Text(user.status.displayName)
                        .font(.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private func colorForStatus(_ status: UserStatus) -> Color {
        switch status.color {
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        default: return .gray
        }
    }
}

struct RequestRow: View {
    let request: APIRequest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(request.method.rawValue)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text(request.endpoint)
                        .font(.caption)
                        .lineLimit(1)
                }
                
                Text(request.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForStatus(request.status))
                        .frame(width: 6, height: 6)
                    Text(request.status.displayName)
                        .font(.caption2)
                }
                
                if let responseTime = request.responseTime {
                    Text(String(format: "%.2fs", responseTime))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
    
    private func colorForStatus(_ status: RequestStatus) -> Color {
        switch status.color {
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        default: return .gray
        }
    }
}

struct AddUserView: View {
    @ObservedObject var apiService: MockAPIService
    @State private var name = ""
    @State private var email = ""
    @State private var department = ""
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Department", text: $department)
                }
            }
            .navigationTitle("Add User")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    createUser()
                }
                .disabled(name.isEmpty || email.isEmpty || department.isEmpty)
            )
        }
    }
    
    private func createUser() {
        apiService.createUser(name: name, email: email, department: department)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error creating user: \(error)")
                    }
                    presentationMode.wrappedValue.dismiss()
                },
                receiveValue: { response in
                    print("Created user: \(response.data.name)")
                }
            )
            .store(in: &cancellables)
    }
}