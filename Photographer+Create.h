//
//  Photographer+Create.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *) photographerWithUniqueID:(NSString *)uniqueID withName:(NSString *)name
                     inManagedObjectContext:(NSManagedObjectContext *)context;

@end
