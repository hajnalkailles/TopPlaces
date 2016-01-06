//
//  Photo+CoreDataProperties.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 06/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photo.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *photoURL;
@property (nullable, nonatomic, retain) NSString *subtitle;
@property (nullable, nonatomic, retain) NSData *thumbnailImage;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *uniqueID;
@property (nullable, nonatomic, retain) NSDate *viewDate;
@property (nullable, nonatomic, retain) NSNumber *didView;
@property (nullable, nonatomic, retain) Region *placeTaken;
@property (nullable, nonatomic, retain) Photographer *whoTook;

@end

NS_ASSUME_NONNULL_END
