//
//  RDMLinkLibraryDelegate.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/3/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDMLink;

@protocol RDMLinkLibraryDelegate <NSObject>

-(void) linkLibraryVC:(UIViewController*)libraryViewController shouldShowEditViewForLink:(RDMLink*)link;
-(void) linkLibraryVC:(UIViewController*)libraryViewController showShowSendViewForLink:(RDMLink*)link;

@end