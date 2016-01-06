//
//  Region+CoreDataProperties.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 05/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Region.h"

NS_ASSUME_NONNULL_BEGIN

@interface Region (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *photoCount;
@property (nullable, nonatomic, retain) NSNumber *photographerCount;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Photographer *> *photographers;
@property (nullable, nonatomic, retain) NSSet<Photo *> *photos;

@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotographersObject:(Photographer *)value;
- (void)removePhotographersObject:(Photographer *)value;
- (void)addPhotographers:(NSSet<Photographer *> *)values;
- (void)removePhotographers:(NSSet<Photographer *> *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet<Photo *> *)values;
- (void)removePhotos:(NSSet<Photo *> *)values;

@end

NS_ASSUME_NONNULL_END
