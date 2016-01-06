//
//  Region+Create.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Region+Create.h"
#import "FlickrFetcher.h"

@implementation Region (Create)

+ (Region *) regionWithData:(NSData *)data withPhotographer:(Photographer *)photographer
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;

    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", regionName];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        //handle error
    } else if ([matches count])
    {
        region = [matches firstObject];
        region.photoCount = @([region.photoCount intValue] +1);
        
        if (![region.photographers member:photographer]) {
            [region addPhotographersObject:photographer];
            region.photographerCount = @([region.photographerCount intValue] + 1);;
        }
    } else {
        region = [NSEntityDescription insertNewObjectForEntityForName: @"Region" inManagedObjectContext:context];
        
        region.name = regionName;
        region.photoCount = [NSNumber numberWithInt:1];
        region.photographerCount = [NSNumber numberWithInt:1];
    }
    
    return region;
}

@end
