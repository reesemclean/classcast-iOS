//
//  RDMOpenLinkHandler.m
//  URLPusher-Student
//
//  Created by Reese McLean on 8/20/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMOpenLinkHandler.h"

#import "RDMStudentLink.h"

@implementation RDMOpenLinkHandler

+(BOOL)openLink:(RDMStudentLink*)link {
    
    BOOL success = NO;
    
    NSString *urlString = link.url;
    NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:escaped];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url];
        success = YES;
    } else {
        //Try prepending http://
        
        NSString *urlStringWithHTTP = [@"http://" stringByAppendingString:escaped];
        url = [NSURL URLWithString:urlStringWithHTTP];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            success = YES;
        }
        
    }
    
    return success;

}

@end
