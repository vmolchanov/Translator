#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Settings : NSManagedObject

+ (UIColor *)colorFromBitwiseMask:(int32_t)bitwiseMask;
+ (int32_t)bitwiseMaskByRedColor:(int32_t)red greenColor:(int32_t)green blueColor:(int32_t)blue;

@end

NS_ASSUME_NONNULL_END

#import "Settings+CoreDataProperties.h"
