//
//  SL_ParseOperation.m
//  LazyFashionTable
//
//  Created by Exile on 17.03.14.
//  Copyright (c) 2014 Exile. All rights reserved.
//

#import "SL_ParseOperation.h"
#import "SL_StoreRecord.h"
#import "HAAppDelegate.h"

@interface SL_ParseOperation ()

@property (nonatomic, strong) NSArray *storeRecordList;
@property (nonatomic, strong) NSData *dataToParse;
@end


@implementation SL_ParseOperation

// -------------------------------------------------------------------------------
//	initWithData:
// -------------------------------------------------------------------------------
- (id)initWithData:(NSData *)data
{
    self = [super init];
    if (self != nil)
    {
        _dataToParse = data;
        HAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return self;
}

// -------------------------------------------------------------------------------
//	main
//  Entry point for the operation.
//  Given data to parse, use JSON Serializer and process everything you get.
// -------------------------------------------------------------------------------
- (void)main
{
    
    NSError *e = nil;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:self.dataToParse options:NSJSONReadingMutableContainers error: &e];
    
    NSLog(@"JSON: %@", JSON);
    NSArray *items = [JSON objectForKey:@"items"];
    [self fillWorkingArrayWithItems: items];
    NSString *dateString = [JSON objectForKey:@"timestamp"];
    NSString *successStatus = [JSON objectForKey:@"status"];
    if([successStatus isEqualToString:@"SUCCESS"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDate *date = [dateFormatter dateFromString:dateString];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"myDateKey"];
    }
    self.dataToParse = nil;
}

- (void)fillWorkingArrayWithItems: (NSArray *)items
{
    //each item we get is either product or creator
    for (NSDictionary *item in items) {
        SL_StoreRecord *thing = [[SL_StoreRecord alloc] init];
        if (([[item allKeys] containsObject:@"product"])
            &&
            (![[item objectForKey:@"product"] isMemberOfClass:[NSNull class]])) {
            NSDictionary *product = [item objectForKey:@"product"];

            thing.thingName = [self getCorrectString:[product objectForKey:@"name"]];
            thing.thingDesc = [self getCorrectString:[product objectForKey:@"desc"]];
            thing.artist = [self getCorrectString:[[product objectForKey:@"brand"] objectForKey:@"bname"]];
            thing.gender  = [self getCorrectString:[[product objectForKey:@"gender"] objectForKey:@"genname"]];
            thing.imageURLString = [self getCorrectString:[self extractMainImageFromArray: [product objectForKey:@"images"]]];
            thing.thingURLString = [self getCorrectString:[product objectForKey:@"url"]];
        } else if (([[item allKeys] containsObject:@"board"])
                   &&
                   ([[[item objectForKey:@"board"] allKeys] containsObject:@"creator"])
                   &&
                   (![[[item objectForKey:@"board"] objectForKey:@"creator"] isMemberOfClass:[NSNull class]])) {
            NSDictionary *creator = [[item objectForKey:@"board"] objectForKey:@"creator"];
            thing.thingName = [NSString stringWithFormat:@"%@ %@", [self getCorrectString:[creator objectForKey:@"firstname"]], [self getCorrectString:[creator objectForKey:@"lastname"] ]];
            thing.artist = [NSString stringWithFormat:@"%@, %@", [self getCorrectString:[creator objectForKey:@"city"]], [self getCorrectString: [creator objectForKey:@"country"]]];
            thing.imageURLString = [NSString stringWithFormat:@"http:%@", [self getCorrectString:[creator objectForKey:@"picture"]]];
            thing.thingURLString = [self getCorrectString:[creator objectForKey:@"url"]];
        }
        FashionEntity * newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"FashionEntity"
                                                          inManagedObjectContext:self.managedObjectContext];
        newEntry.thingName = thing.thingName;
        newEntry.gender = thing.gender;
        newEntry.artist = thing.artist;
        newEntry.imageURLString = thing.imageURLString;
        newEntry.thingURLString = thing.thingURLString;
        newEntry.thingDesc = thing.thingDesc;
    }
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (NSString *)getCorrectString:(id)stringObject
{
    NSString *goodString = @"unknown";
    if([stringObject isKindOfClass:[NSString class]])
        goodString = stringObject;
    return goodString;
}

- (NSString *)extractMainImageFromArray: (NSArray *)itemImages
{
    for (NSDictionary *imageDictionary in itemImages) {
        if([[imageDictionary objectForKey:@"primary"] intValue] == 1)
            return [imageDictionary objectForKey:@"url"];
    }
    return @"";
}

@end
