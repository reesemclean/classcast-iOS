//
//  RDMStudentSyncEngine.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const RDMSyncEngineDidFinishNotification;

@interface RDMStudentSyncEngine : NSObject

+(instancetype) sharedEngine;

-(void) startSync;
-(void) startFullResync;
@property (nonatomic, assign, readonly) BOOL isSyncing;

@end
