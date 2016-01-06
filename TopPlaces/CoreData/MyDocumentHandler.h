//
//  MyDocumentHandler.h
//  TopPlaces
//
//  Created by Hegyi Hajnalka on 04/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface MyDocumentHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) UIManagedDocument *document;

+ (MyDocumentHandler *)sharedDocumentHandler;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end
