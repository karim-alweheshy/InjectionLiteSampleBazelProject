//
//  UserProfileModel.swift
//  UserProfile
//
//  Created by Karim Alweheshy on 31.07.25.
//

import Foundation

struct UserProfile {
    var name: String
    var email: String
    var age: Int
    var profileImageName: String
    var joinDate: Date
    var preferences: UserPreferences
    var stats: UserStats
}

struct UserPreferences {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String
}

struct UserStats {
    var totalSessions: Int
    var averageSessionDuration: TimeInterval
    var favoriteFeatures: [String]
}

class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isEditing: Bool = false
    
    init() {
        self.userProfile = UserProfile(
            name: "John Doe",
            email: "john.doe@example.com",
            age: 28,
            profileImageName: "person.circle.fill",
            joinDate: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date(),
            preferences: UserPreferences(
                notificationsEnabled: true,
                darkModeEnabled: false,
                language: "English"
            ),
            stats: UserStats(
                totalSessions: 142,
                averageSessionDuration: 245.0,
                favoriteFeatures: ["Analytics", "Profile", "Settings"]
            )
        )
    }
    
    func updateProfile(name: String, email: String, age: Int) {
        userProfile.name = name
        userProfile.email = email
        userProfile.age = age
    }
    
    func toggleNotifications() {
        userProfile.preferences.notificationsEnabled.toggle()
    }
    
    func toggleDarkMode() {
        userProfile.preferences.darkModeEnabled.toggle()
    }
}
