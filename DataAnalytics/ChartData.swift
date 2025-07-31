//
//  ChartData.swift
//  DataAnalytics
//
//  Created by Karim Alweheshy on 31.07.25.
//

import Foundation

struct ChartDataPoint {
    let x: Double
    let y: Double
}

struct ChartDataset {
    let label: String
    let data: [ChartDataPoint]
    let color: String
}

struct AnalyticsStats {
    let average: Double
    let maximum: Double
    let minimum: Double
    let dataCount: Int
}

class ChartDataManager: ObservableObject {
    @Published var datasets: [ChartDataset] = []
    @Published var stats: AnalyticsStats = AnalyticsStats(average: 0, maximum: 0, minimum: 0, dataCount: 0)
    @Published var isLoading: Bool = false
    
    func generateSampleData() {
        isLoading = true
        
        DispatchQueue.global(qos: .background).async {
            // Use Objective-C DataProcessor to generate and process data
            let rawData = DataProcessor.generateSampleData(30)
            let processedData = DataProcessor.processRawData(rawData)
            
            let average = DataProcessor.calculateAverage(processedData)
            let maximum = DataProcessor.findMaxValue(processedData).doubleValue
            let minimum = DataProcessor.findMinValue(processedData).doubleValue
            
            // Convert to chart data points
            var dataPoints: [ChartDataPoint] = []
            for (index, value) in processedData.enumerated() {
                dataPoints.append(ChartDataPoint(x: Double(index), y: value.doubleValue))
            }
            
            let dataset = ChartDataset(
                label: "Sample Analytics Data",
                data: dataPoints,
                color: "blue"
            )
            
            let newStats = AnalyticsStats(
                average: average,
                maximum: maximum,
                minimum: minimum,
                dataCount: processedData.count
            )
            
            DispatchQueue.main.async {
                self.datasets = [dataset]
                self.stats = newStats
                self.isLoading = false
            }
        }
    }
    
    func refreshData() {
        generateSampleData()
    }
}