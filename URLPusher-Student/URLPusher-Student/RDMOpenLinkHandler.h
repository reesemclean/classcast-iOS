//
//  RDMOpenLinkHandler.h
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDMStudentLink;

@interface RDMOpenLinkHandler : NSObject

+(BOOL)openLink:(RDMStudentLink*)link;

@end
