//
//  UserProfileView.swift
//  UserProfile
//
//  Created by Karim Alweheshy on 31.07.25.
//

import SwiftUI
import Inject

public struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @ObserveInjection var inject
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader
                    
                    
                    // User Stats
                    userStats
                    
                    // Preferences
                    preferencesSection
                    
                    // Edit Profile Button
                    editProfileButton
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .enableInjection()
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.userProfile.profileImageName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text(viewModel.userProfile.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.userProfile.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Age: \(viewModel.userProfile.age)")
                .font(.body)
                .foregroundColor(.secondary)

                Text("Age: \(viewModel.userProfile.age)")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text("Member since \(viewModel.userProfile.joinDate, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var userStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usage Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.userProfile.stats.totalSessions)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg. Session Duration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(viewModel.userProfile.stats.averageSessionDuration / 60))m")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            Text("Favorite Features")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(viewModel.userProfile.stats.favoriteFeatures, id: \.self) { feature in
                    Text(feature)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Text("Notifications")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.userProfile.preferences.notificationsEnabled },
                    set: { _ in viewModel.toggleNotifications() }
                ))
            }
            
            HStack {
                Text("Dark Mode")
                Spacer()
                Toggle("", isOn: Binding(
                    get: { viewModel.userProfile.preferences.darkModeEnabled },
                    set: { _ in viewModel.toggleDarkMode() }
                ))
            }
            
            HStack {
                Text("Language")
                Spacer()
                Text(viewModel.userProfile.preferences.language)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var editProfileButton: some View {
        Button(action: {
            viewModel.isEditing.toggle()
        }) {
            Text("Edit Profile")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .sheet(isPresented: $viewModel.isEditing) {
            EditProfileView(viewModel: viewModel)
        }
    }
}

struct EditProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @State private var tempName: String = ""
    @State private var tempEmail: String = ""
    @State private var tempAge: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $tempName)
                    TextField("Email", text: $tempEmail)
                    TextField("Age", text: $tempAge)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    if let age = Int(tempAge) {
                        viewModel.updateProfile(name: tempName, email: tempEmail, age: age)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            tempName = viewModel.userProfile.name
            tempEmail = viewModel.userProfile.email
            tempAge = String(viewModel.userProfile.age)
        }
    }
}