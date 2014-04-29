//
//  SL_ParseOperation.h
//  LazyFashionTable
//
//  Created by Exile on 17.03.14.
//  Copyright (c) 2014 Exile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAAppDelegate.h"
#import "FashionEntity.h"
#import <CoreData/CoreData.h>

@interface SL_ParseOperation : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);
// ManagedObjectContext - to save new entries
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
// NSArray containing StoreRecord instances for each entry parsed
// from the input data.
// Only meaningful after the operation has completed.
@property (nonatomic, strong, readonly) NSArray *storeRecordList;

// The initializer for this NSOperation subclass.
- (id)initWithData:(NSData *)data;

@end
