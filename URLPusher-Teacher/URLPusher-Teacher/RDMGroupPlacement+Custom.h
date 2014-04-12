//
//  RDMGroupPlacement+Custom.h
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/16/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMGroupPlacement.h"

typedef NS_ENUM(NSUInteger, RDMGroupPlacementType) {
    
    RDMGroupPlacementTypeAdded = 0,
    RDMGroupPlacementTypeRemoved = 1
    
};

@interface RDMGroupPlacement (Custom)

-(NSDictionary*)groupPlacementDictionary;

@end
