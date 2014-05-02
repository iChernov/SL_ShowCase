//
//  HAAppDelegate.h
//  Paper
//
//  Created by Heberti Almeida on 03/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

@import UIKit;
#import <CoreData/CoreData.h>

@interface HAAppDelegate : UIResponder <UIApplicationDelegate> {
    NSManagedObjectModel *_managedObjectModel;
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow *window;

- (NSString *)applicationDocumentsDirectory;
- (NSArray*)getAllFashionRecords;
- (void)loadRecordsFrom:(int)amountOfLoadedRecords;
- (void)eraseAllRecords;
- (void)reloadWithGender:(NSInteger)genderIndex;

@end
