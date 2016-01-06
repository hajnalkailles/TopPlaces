//
//  Photographer+Create.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Photographer+Create.h"
#import "FlickrFetcher.h"

@implementation Photographer (Create)

+ (Photographer *) photographerWithUniqueID:(NSString *)uniqueID withName:(NSString *)name
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", uniqueID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        //handle error
    } else if ([matches count])
    {
        photographer = [matches firstObject];
    } else {
        photographer = [NSEntityDescription insertNewObjectForEntityForName: @"Photographer" inManagedObjectContext:context];
        
        photographer.uniqueID = uniqueID;
        photographer.name = name;
    }
    
    return photographer;
}

@end
