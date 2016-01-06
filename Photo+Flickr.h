//
//  Photo+Flickr.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *) photoWithFlickrData:(NSDictionary *)flickrData
         inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos
         intoManagedObjectContext:(NSManagedObjectContext *)context;

+ (Photo *) addDateToPhotoWithURL:(NSString *)urlString inManagedObjectContext:(NSManagedObjectContext *)context;

@end
