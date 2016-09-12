//
//  CardView.m
//  IGuess
//
//  Created by xia on 9/12/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Shadow
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Corner Radius
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Background Color
//    sself.layer.backgroundColor = [UIColor orangeColor].CGColor;
    self.layer.backgroundColor = [UIColor colorWithRed:102 green:204 blue:255 alpha:1].CGColor;
}

- (void)setLabel:(NSString *)note {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, 80, 100, 100)];
    label.text = note;
    label.font = [UIFont fontWithName:@"Arial" size:25];
    [self addSubview:label];
    
}

@end
