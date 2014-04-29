//
//  HAPaperCollectionViewController.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "HAPaperCollectionViewController.h"
#import "HATransitionLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SL_StoreRecord.h"
#import "SL_FashionCell.h"

#define MAX_COUNT 20
#define CELL_ID @"CELL_ID"

@interface HAPaperCollectionViewController () {
    
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
    
}

@end


@implementation HAPaperCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_ID];
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Hide StatusBar
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                @try {
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    _webImageOperation = [manager downloadWithURL:_photoURL
                                                          options:0
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             if (expectedSize > 0) {
                                                                 float progress = receivedSize / (float)expectedSize;
                                                                 NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                       [NSNumber numberWithFloat:progress], @"progress",
                                                                                       self, @"photo", nil];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
                                                             }
                                                         }
                                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                            if (error) {
                                                                MWLog(@"SDWebImage failed to download image: %@", error);
                                                            }
                                                            _webImageOperation = nil;
                                                            self.underlyingImage = image;
                                                            [self imageLoadingComplete];
                                                        }];
                } @catch (NSException *e) {
                    NSLog(@"Photo from web: %@", e);
                    _webImageOperation = nil;
                    [self imageLoadingComplete];
                }
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = [UIImage imageWithData:storeRecord.thingImageData];
        }
        
    }
    
    return cell;
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
