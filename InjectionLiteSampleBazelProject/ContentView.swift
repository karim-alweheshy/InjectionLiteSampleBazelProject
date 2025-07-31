//
//  ContentView.swift
//  InjectionLiteSampleBazelProject
//
//  Created by Karim Alweheshy on 30.07.25.
//

import SwiftUI
import Foundation
import Inject
import UserProfile
import DataAnalytics
import NetworkService

struct ContentView: View {
    @ObserveInjection var inject
    
    var body: some View {
        NavigationView {
            DashboardView()
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force single view on iPad
        .enableInjection()
    }
}

struct DashboardView: View {
    @ObserveInjection var inject
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Feature Cards
                    featureCardsSection
                    
                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
        .enableInjection()
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to Sample App")
                .font(.title)
                .fontWeight(.bold)
            
            Text("A multi-module iOS application demonstrating Bazel integration with Swift and Objective-C")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickStatCard(
                    title: "Modules",
                    value: "4",
                    subtitle: "Swift & Obj-C",
                    color: .blue
                )
                
                QuickStatCard(
                    title: "Features",
                    value: "12+",
                    subtitle: "Interactive",
                    color: .green
                )
                
                QuickStatCard(
                    title: "Architecture",
                    value: "Bazel",
                    subtitle: "Multi-target",
                    color: .orange
                )
                
                QuickStatCard(
                    title: "Hot Reload",
                    value: "✓",
                    subtitle: "Enabled",
                    color: .purple
                )
            }
        }
    }
    
    private var featureCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore Features")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                NavigationLink(destination: NavigationDestination.view(for: .userProfile)) {
                    FeatureCard(
                        icon: "person.circle.fill",
                        title: "User Profile",
                        description: "Manage user information, preferences, and view usage statistics",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: NavigationDestination.view(for: .analytics)) {
                    FeatureCard(
                        icon: "chart.bar.fill",
                        title: "Data Analytics",
                        description: "Visualize data with charts powered by Objective-C processing",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: NavigationDestination.view(for: .networkService)) {
                    FeatureCard(
                        icon: "network",
                        title: "Network Service",
                        description: "Mock API interactions with request monitoring and user management",
                        color: .orange
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ActivityItem(
                    icon: "gear",
                    text: "App initialized with multi-module architecture",
                    time: "Now"
                )
                
                ActivityItem(
                    icon: "swift",
                    text: "Swift modules loaded successfully",
                    time: "1s ago"
                )
                
                ActivityItem(
                    icon: "c.circle",
                    text: "Objective-C integration enabled",
                    time: "2s ago"
                )
                
                ActivityItem(
                    icon: "hammer.fill",
                    text: "Bazel build system ready",
                    time: "3s ago"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ActivityItem: View {
    let icon: String
    let text: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.caption)
                .lineLimit(2)
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}
