//
//  RDMSyncEngine.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/6/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RDMSyncEngineDidFinishNotification;

@class RDMUser;

@interface RDMSyncEngine : NSObject

+(instancetype) sharedEngine;

-(void) startSync;
@property (nonatomic, assign, readonly) BOOL isSyncing;

@end
