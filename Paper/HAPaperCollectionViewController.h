//
//  HAPaperCollectionViewController.h
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

@import UIKit;
#import <CoreData/CoreData.h>

@interface HAPaperCollectionViewController : UICollectionViewController

<NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

- (IBAction)eraseCachedData:(id)sender;
- (UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *entries;


@end
