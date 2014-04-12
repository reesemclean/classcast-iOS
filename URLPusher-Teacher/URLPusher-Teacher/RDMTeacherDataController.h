//
//  RDMTeacherDataController.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@class RDMUser;

typedef void (^RDMCoreDataSaveCompletionBlock) (NSError *error);

@interface RDMTeacherDataController : NSObject

+(instancetype) sharedInstance;

@property (nonatomic, strong) RDMUser *currentUser;

//Main Context
@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
-(BOOL) saveMainContextSyncronously:(NSError **)error;
-(void) saveMainContextWithCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock;

//Temporary Context
-(NSManagedObjectContext*) createTemporaryContext;
-(void) saveTemporaryContextAndPushToMainContext:(NSManagedObjectContext*)temporaryContext
                                  withCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock;

@end
