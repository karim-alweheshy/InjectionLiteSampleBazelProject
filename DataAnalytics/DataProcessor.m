//
//  DataProcessor.m
//  DataAnalytics
//
//  Created by Karim Alweheshy on 31.07.25.
//

#import "DataProcessor.h"

@implementation DataProcessor

+ (NSArray<NSNumber *> *)processRawData:(NSArray<NSNumber *> *)rawData {
    NSMutableArray<NSNumber *> *processedData = [[NSMutableArray alloc] init];
    
    for (NSNumber *value in rawData) {
        // Simple processing: normalize and smooth the data
        double normalizedValue = [value doubleValue] * 1.2 + 10;
        [processedData addObject:@(normalizedValue)];
    }
    
    return [processedData copy];
}

+ (double)calculateAverage:(NSArray<NSNumber *> *)data {
    if (data.count == 0) return 0.0;
    
    double sum = 0.0;
    for (NSNumber *value in data) {
        sum += [value doubleValue];
    }
    
    return sum / data.count;
}

+ (NSNumber *)findMaxValue:(NSArray<NSNumber *> *)data {
    if (data.count == 0) return @(0);
    
    double maxValue = [[data firstObject] doubleValue];
    for (NSNumber *value in data) {
        double currentValue = [value doubleValue];
        if (currentValue > maxValue) {
            maxValue = currentValue;
        }
    }
    
    return @(maxValue);
}

+ (NSNumber *)findMinValue:(NSArray<NSNumber *> *)data {
    if (data.count == 0) return @(0);
    
    double minValue = [[data firstObject] doubleValue];
    for (NSNumber *value in data) {
        double currentValue = [value doubleValue];
        if (currentValue < minValue) {
            minValue = currentValue;
        }
    }
    
    return @(minValue);
}

+ (NSArray<NSNumber *> *)generateSampleData:(NSInteger)count {
    NSMutableArray<NSNumber *> *sampleData = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < count; i++) {
        // Generate random data points between 0 and 100
        double randomValue = arc4random_uniform(100) + (arc4random_uniform(100) / 100.0);
        [sampleData addObject:@(randomValue)];
    }
    
    return [sampleData copy];
}

@end