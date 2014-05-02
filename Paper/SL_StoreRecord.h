//
//  SL_StoreRecord.h
//  LazyFashionTable
//
//  Created by Exile on 17.03.14.
//  Copyright (c) 2014 Exile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SL_StoreRecord : NSObject

@property (nonatomic, strong) NSString *thingName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSData *thingImageData;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *thingURLString;
@property (nonatomic, strong) NSString *thingDesc;

@end
