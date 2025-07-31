//
//  AnalyticsView.swift
//  DataAnalytics
//
//  Created by Karim Alweheshy on 31.07.25.
//

import SwiftUI
import Inject

public struct AnalyticsView: View {
    @StateObject private var dataManager = ChartDataManager()
    @ObserveInjection var inject
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics Cards
                    statisticsSection
                    
                    // Chart Section
                    chartSection
                    
                    // Data Processing Info
                    processingInfoSection
                    
                    // Refresh Button
                    refreshButton
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if dataManager.datasets.isEmpty {
                dataManager.generateSampleData()
            }
        }
        .enableInjection()
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(title: "Average", value: String(format: "%.1f", dataManager.stats.average), color: .blue)
                StatCard(title: "Maximum", value: String(format: "%.1f", dataManager.stats.maximum), color: .green)
                StatCard(title: "Minimum", value: String(format: "%.1f", dataManager.stats.minimum), color: .orange)
                StatCard(title: "Data Points", value: "\(dataManager.stats.dataCount)", color: .purple)
            }
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data Visualization")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dataManager.isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Processing data with Objective-C...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                SimpleLineChart(dataset: dataManager.datasets.first)
            }
        }
    }
    
    private var processingInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Data Processing Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                    Text("Processed using Objective-C DataProcessor")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.green)
                    Text("Data normalized and smoothed")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.orange)
                    Text("Statistical analysis computed")
                        .font(.caption)
                }
            }
            .padding(.leading, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var refreshButton: some View {
        Button(action: {
            dataManager.refreshData()
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Refresh Data")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
        .disabled(dataManager.isLoading)
    }
}

public struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    public init(title: String, value: String, color: Color) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            Text(title)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SimpleLineChart: View {
    let dataset: ChartDataset?
    
    var body: some View {
        GeometryReader { geometry in
            if let dataset = dataset, !dataset.data.isEmpty {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let maxX = dataset.data.map { $0.x }.max() ?? 1
                    let maxY = dataset.data.map { $0.y }.max() ?? 1
                    let minY = dataset.data.map { $0.y }.min() ?? 0
                    
                    let yRange = maxY - minY
                    
                    for (index, point) in dataset.data.enumerated() {
                        let x = (point.x / maxX) * width
                        let y = height - ((point.y - minY) / yRange) * height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                .background(
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .cornerRadius(12)
                )
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
        .frame(height: 200)
    }
}