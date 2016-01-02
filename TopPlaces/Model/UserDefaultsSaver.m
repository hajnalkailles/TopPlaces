//
//  UserDefaultsSaver.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 01/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "UserDefaultsSaver.h"
#import "FlickrFetcher.h"

@implementation UserDefaultsSaver

+ (void)addNewImage:(NSDictionary *)imageDictionary
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"])
    {
        [imagesArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"]];
        for (NSDictionary *imageDict in imagesArray)
        {
            if ([imageDict isEqual:imageDictionary])
            {
                [imagesArray removeObject:imageDict];
                break;
            }
        }
        if ([imagesArray count] == 20)
        {
            [imagesArray removeObject:[imagesArray lastObject]];
        }
        [imagesArray insertObject:imageDictionary atIndex:0];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recentPictures"];
    } else
    {
        [imagesArray addObject: imageDictionary];
    }
    [[NSUserDefaults standardUserDefaults] setObject:imagesArray forKey:@"recentPictures"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getRecentImages
{
    NSMutableArray *recentImages = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"])
    {
        recentImages = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"];
    }
    return recentImages;
}

@end
