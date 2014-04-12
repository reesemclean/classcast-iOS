//
//  UIAlertView+ErrorHelpers.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 8/13/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "UIAlertView+ErrorHelpers.h"

@implementation UIAlertView (ErrorHelpers)

+(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
