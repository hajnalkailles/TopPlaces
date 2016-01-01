//
//  UserDefaultsSaver.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 01/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsSaver : NSObject

+ (void)addNewImageURL:(NSURL *)imageURL;
+ (NSArray *)getRecentImages;

@end
