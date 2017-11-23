#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface CoreDataManager : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;

+ (CoreDataManager *)defaultManager;
+ (UIColor *)colorFromBitwiseMask:(int32_t)bitwiseMask;
+ (int32_t)bitwiseMaskByRedColor:(int32_t)red greenColor:(int32_t)green blueColor:(int32_t)blue;

@end
