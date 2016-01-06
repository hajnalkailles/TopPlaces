//
//  PlacesPhotoTableViewController.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 28/12/15.
//  Copyright © 2015 Hegyi Hajnalka. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PlacesPhotoTableViewController : CoreDataTableViewController
@property (nonatomic) NSString *regionName;
@property (nonatomic, strong) NSManagedObjectContext *context;
@end
