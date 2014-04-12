//
//  RDMBlurredGradientView.m
//  URLPusher-Teacher
//
//  Created by Reese McLean on 7/31/13.
//  Copyright (c) 2013 Reese McLean. All rights reserved.
//

#import "RDMBlurredGradientView.h"

@implementation RDMBlurredGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

+ (Class) layerClass {
    return [CAGradientLayer class];
}

-(void) awakeFromNib {
    
    UIColor *colorOne = [UIColor colorWithRed:(58.0/255.0)
                                        green:(95.0/255.0)
                                         blue:(117.0/255.0)
                                        alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(60.0/255.0)  green:(99.0/255.0)  blue:(122.0/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = (CAGradientLayer*)self.layer;
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
