//
//  SL_IconDownloader.h
//  LazyFashionTable
//
//  Created by Exile on 17.03.14.
//  Copyright (c) 2014 Exile. All rights reserved.
//

@class SL_StoreRecord;

#import <Foundation/Foundation.h>

@interface SL_IconDownloader : NSObject

@property (nonatomic, strong) SL_StoreRecord *storeRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
