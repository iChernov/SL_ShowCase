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
#import "HACollectionViewLargeLayout.h"
#import "HATransitionLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SL_StoreRecord.h"
#import "SL_FashionCell.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageManager.h"
#import "SDWebImageOperation.h"

#define CELL_ID @"CELL_ID"
@interface HAPaperCollectionViewController () <UIScrollViewDelegate> {
    BOOL _loadingInProgress;
    NSInteger _previousLoadCaller;
    id <SDWebImageOperation> _webImageOperation;
}
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end


@implementation HAPaperCollectionViewController 

- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        _previousLoadCaller = -1;
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
        
        cell.textView.text = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", storeRecord.thingName, storeRecord.artist, storeRecord.thingDesc];
		
        // Only load cached images; defer new downloads until scrolling ends
        if (!storeRecord.thingImageData)
        {

               [self startIconDownload:storeRecord forIndexPath:indexPath];

            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageWithData:storeRecord.thingImageData];
        }
        
    }
    if (indexPath.row == nodeCount - 3)
        [self launchAdditionalLoadWithCaller:indexPath.row];
    return cell;
}

- (void)launchAdditionalLoadWithCaller:(NSInteger)callerID
{
    if(_previousLoadCaller != callerID)
    {
        _previousLoadCaller = callerID;
        HAAppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate loadRecordsFrom: (int)[self.entries count]];
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.entries count];
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

- (void) encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
}

- (void) decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
}


@end
