//
//  HAPaperCollectionViewController.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HAAppDelegate.h"
#import "SL_IconDownloader.h"
#import "HAPaperCollectionViewController.h"
#import "HATransitionLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SL_StoreRecord.h"
#import "SL_FashionCell.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageManager.h"
#import "SDWebImageOperation.h"

#define MAX_COUNT 15
#define CELL_ID @"CELL_ID"

@interface HAPaperCollectionViewController () <UIScrollViewDelegate> {
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
}
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end


@implementation HAPaperCollectionViewController 

- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[SL_FashionCell class] forCellWithReuseIdentifier:CELL_ID];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    HAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)startIconDownload:(SL_StoreRecord *)storeRecord forIndexPath:(NSIndexPath *)indexPath
{
    SL_IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[SL_IconDownloader alloc] init];
        iconDownloader.storeRecord = storeRecord;
        [iconDownloader setCompletionHandler:^{
            
            SL_FashionCell *cell = (SL_FashionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            // Display the newly loaded image
            
            cell.imageView.image  = [UIImage imageWithData:storeRecord.thingImageData];
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SL_FashionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 4;
    cell.clipsToBounds = YES;
    
    NSUInteger nodeCount = [self.entries count];
    
    if (nodeCount == 0 && indexPath.row == 0)
	{
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame: cell.frame];
        loadingLabel.text = @"Loading…";
        [cell.contentView addSubview:loadingLabel];
		return cell;
    }
    
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
    cell.backgroundView = backgroundView;
    
    if (nodeCount > 0)
	{
        // Set up the cell...
        SL_StoreRecord *storeRecord = [self.entries objectAtIndex:indexPath.row];
        
        cell.titleLabel.font = [UIFont systemFontOfSize:11.0];
        cell.titleLabel.numberOfLines = 2;
        cell.titleLabel.adjustsFontSizeToFitWidth = YES;
        
		cell.titleLabel.text = storeRecord.thingName;
        
        cell.detailsLabel.font = [UIFont systemFontOfSize:10.0];
        cell.detailsLabel.text = storeRecord.artist;
		
        // Only load cached images; defer new downloads until scrolling ends
        if (!storeRecord.thingImageData)
        {
            NSLog(@"DRAGGING: %hhd", self.collectionView.dragging);

               [self startIconDownload:storeRecord forIndexPath:indexPath];

            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageWithData:storeRecord.thingImageData];
        }
        
    }
    NSLog(@"%d %d", indexPath.row, nodeCount);
    if (indexPath.row == nodeCount - 2)
        [self launchAdditionalLoad];
    return cell;
}

- (void)launchAdditionalLoad
{
    HAAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate loadRecordsFrom: [self.entries count]];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX_COUNT;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point
{
    return nil;
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    HATransitionLayout *transitionLayout = [[HATransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Adjust scrollView decelerationRate
    self.collectionView.decelerationRate = self.class != [HAPaperCollectionViewController class] ? UIScrollViewDecelerationRateNormal : UIScrollViewDecelerationRateFast;
}

@end
