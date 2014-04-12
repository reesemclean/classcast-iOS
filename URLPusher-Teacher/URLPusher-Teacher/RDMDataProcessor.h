//
//  RDMDataProcessor.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/7/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDMUser;
@class RDMLink;
#import "RDMTeacherDataController.h"

@interface RDMDataProcessor : NSObject

-(id) initWithDataController:(RDMTeacherDataController*)dataController;

-(void) updateUser:(RDMUser*)user
withUserDictionary:(NSDictionary*)userDictionary
withArrayOfLinkDictionaries:(NSArray*)linkDictionaries
andArrayOfDeviceDictionaries:(NSArray*)deviceDictionaries
andArrayOfGroupDictionaries:(NSArray*)groupDictionaries
andArrayOfGroupPlacementChanges:(NSArray*)groupPlacementChanges
    withCompletion:(RDMCoreDataSaveCompletionBlock)completion;

@end
