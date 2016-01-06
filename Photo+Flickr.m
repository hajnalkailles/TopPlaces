//
//  Photo+Flickr.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Photographer+Create.h"
#import "Region+Create.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)

+ (Photo *) photoWithFlickrData:(NSDictionary *)flickrData
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *uniqueID = [flickrData valueForKey:FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", uniqueID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        //handle error
    } else if ([matches count])
    {
        photo = [matches firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName: @"Photo" inManagedObjectContext:context];
        
        photo.uniqueID = [flickrData valueForKey:FLICKR_PHOTO_ID];
        photo.title = [flickrData valueForKey: FLICKR_PHOTO_TITLE];
        photo.subtitle = [flickrData valueForKey: FLICKR_PHOTO_DESCRIPTION];
        photo.photoURL = [NSString stringWithFormat: @"%@", [FlickrFetcher URLforPhoto:flickrData format:FlickrPhotoFormatOriginal]];
        
        Photographer *photoOwner = [Photographer photographerWithUniqueID:[flickrData valueForKey: FLICKR_PHOTO_OWNER] withName:[flickrData valueForKey: @"ownername"] inManagedObjectContext:context];
        photo.whoTook = photoOwner;
        
        
        [[NSOperationQueue currentQueue] addOperationWithBlock:^{
            [[[NSURLSession sharedSession] dataTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:[flickrData valueForKey:FLICKR_PHOTO_PLACE_ID]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    Region *region = [Region regionWithData:data withPhotographer: photoOwner inManagedObjectContext:context];
                    photo.placeTaken = region;
            }] resume];
        }];
    
    }
    
    return photo;
}

+ (Photo *) addDateToPhotoWithURL:(NSString *)urlString inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat: @"photoURL LIKE %@", urlString];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        //handle error
    } else if ([matches count])
    {
        photo = [matches firstObject];
        NSCalendar *cal = [NSCalendar currentCalendar];
        
        NSDate *date = [NSDate date];
        NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitSecond)
                                         fromDate:date];
        NSDate *today = [cal dateFromComponents:comps];
        photo.viewDate = today;
        photo.didView = [NSNumber numberWithBool:YES];
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    int index = 0;
    while (index < 10) {
        [self photoWithFlickrData:[photos objectAtIndex:index] inManagedObjectContext:context];
        index++;
    }
    //for (NSDictionary *photo in photos) {
    //    [self photoWithFlickrData:photo inManagedObjectContext:context];
    //}
}

@end
