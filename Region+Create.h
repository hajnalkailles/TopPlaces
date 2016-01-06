//
//  Region+Create.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "Region.h"

@interface Region (Create)

+ (Region *) regionWithData:(NSData *)data withPhotographer:(Photographer *)photographer
     inManagedObjectContext:(NSManagedObjectContext *)context;

@end
