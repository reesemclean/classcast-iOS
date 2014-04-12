//
//  RDMStudentDataController.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/9/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMStudentDataController.h"

@interface RDMStudentDataController ()

-(void) setupCoreDataStack;
@property (readwrite, nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation RDMStudentDataController

+(instancetype) sharedInstance {
    static RDMStudentDataController *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[RDMStudentDataController alloc] init];
    });
    
    return _sharedController;
}

-(instancetype) init {
    
    self = [super init];
    if (self) {
        [self setupCoreDataStack];
        [self findOrCreateDevice];
    }
    return self;
}

#pragma mark - Saving Main Context

-(void) findOrCreateDevice {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"RDMStudentDevice"];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request
                                                                error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
    
    self.device = [results firstObject];
    
    if (!self.device) {
        self.device = [NSEntityDescription insertNewObjectForEntityForName:@"RDMStudentDevice"
                                                    inManagedObjectContext:self.managedObjectContext];
        NSError *error = nil;
        if (![self saveMainContextSyncronously:&error]) {
            
            NSLog(@"Could not create device: %@", error);
            
        }
        
    }
    
}

-(BOOL) saveMainContextSyncronously:(NSError **)error {
    
    __block BOOL saveSuccess;
    __block NSError *innerError = nil;
    [self.managedObjectContext performBlockAndWait:^{
        
        saveSuccess = [self.managedObjectContext save:&innerError];
        
    }];
    
    if (!saveSuccess) {
        // handle the error.
        if (error) {
            *error = innerError;
        }
        return NO;
    }
    
    return YES;
}

-(void) saveMainContextWithCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock {
    
    // save parent to disk asynchronously
    [self.managedObjectContext performBlock:^{
        NSError *error;
        if (![self.managedObjectContext save:&error])
        {
            // handle error
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
}

#pragma mark - Child Context

-(NSManagedObjectContext*) createTemporaryContext {
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.managedObjectContext;
    return temporaryContext;
}

-(void) saveTemporaryContextAndPushToMainContext:(NSManagedObjectContext*)temporaryContext withCompletion:(RDMCoreDataSaveCompletionBlock)completionBlock {
    
    [temporaryContext performBlock:^{
        // do something that takes some time asynchronously using the temp context
        
        // push to parent
        NSError *error;
        if (![temporaryContext save:&error])
        {
            // handle error
            if (completionBlock) {
                completionBlock(error);
            }
            return;
        }
        
        [self saveMainContextWithCompletion:^(NSError* error) {
            
            if (error) {
                completionBlock(error);
                return;
            }
            
            completionBlock(nil);
            
        }];
        
    }];
    
}


#pragma mark Setup Core Data Stack

-(void) setupCoreDataStack {
    
    // setup managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"URLPusher-Student" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:[self databaseFileURL]
                                                         options:nil
                                                           error:&error]) {
        // handle error
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
    }
    
    // create MOC
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
}

// Returns the URL to the application's Documents directory.
- (NSURL *)databaseFileURL
{
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *fileName = @"Database-Student.db";
    return [directory URLByAppendingPathComponent:fileName];
}

@end
