//
//  DataProcessor.h
//  DataAnalytics
//
//  Created by Karim Alweheshy on 31.07.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataProcessor : NSObject

+ (NSArray<NSNumber *> *)processRawData:(NSArray<NSNumber *> *)rawData;
+ (double)calculateAverage:(NSArray<NSNumber *> *)data;
+ (NSNumber *)findMaxValue:(NSArray<NSNumber *> *)data;
+ (NSNumber *)findMinValue:(NSArray<NSNumber *> *)data;
+ (NSArray<NSNumber *> *)generateSampleData:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END