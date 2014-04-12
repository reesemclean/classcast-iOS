//
//  RDMStudentDataController.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDMStudentDevice;

typedef void (^RDMCoreDataSaveCompletionBlock) (NSError *error);

@interface RDMStudentDataController : NSObject

@property (nonatomic, strong) RDMStudentDevice *device;

+(instancetype) sharedInstance;

//Main Context
@property (readonly, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
-(BOOL) saveMainContextSyncronously:(NSError **)error;
-(void) saveMainContextWithCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock;

//Temporary Context
-(NSManagedObjectContext*) createTemporaryContext;
-(void) saveTemporaryContextAndPushToMainContext:(NSManagedObjectContext*)temporaryContext
                                  withCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock;

@end
