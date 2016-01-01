//
//  UserDefaultsSaver.m
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 01/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "UserDefaultsSaver.h"

@implementation UserDefaultsSaver

+ (void)addNewImageURL:(NSURL *)imageURL
{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"])
    {
        [imagesArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"]];
        for (NSString *imageDictURL in imagesArray)
        {
            if ([imageDictURL isEqualToString:[NSString stringWithFormat:@"%@", imageURL]])
            {
                [imagesArray removeObject:imageDictURL];
                break;
            }
        }
        if ([imagesArray count] == 20)
        {
            [imagesArray removeObject:[imagesArray lastObject]];
        }
        [imagesArray insertObject:[NSString stringWithFormat:@"%@", imageURL] atIndex:0];
    } else
    {
        [imagesArray addObject: [NSString stringWithFormat:@"%@", imageURL]];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recentPictures"];
    [[NSUserDefaults standardUserDefaults] setObject:imagesArray forKey:@"recentPictures"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)getRecentImages
{
    NSMutableArray *recentImages = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"])
    {
        NSArray *recentImagesString = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPictures"];
        for (NSString *imageString in recentImagesString)
        {
            NSURL *url = [[NSURL alloc] initWithString:imageString];
            [recentImages addObject:url];
        }
    }
    return recentImages;
}

@end
