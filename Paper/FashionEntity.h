//
//  FashionEntity.h
//  Showcase
//
//  Created by Exile on 29.04.14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FashionEntity : NSManagedObject

@property (nonatomic, retain) NSString * thingURLString;
@property (nonatomic, retain) NSString * thingName;
@property (nonatomic, retain) NSData * thingImageData;
@property (nonatomic, retain) NSString * imageURLString;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * artist;

@end
