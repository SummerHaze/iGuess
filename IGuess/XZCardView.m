//
//  XZCardView.m
//  IGuess
//
//  Created by xia on 9/12/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "XZCardView.h"

@interface XZCardView()

@property(nonatomic, strong) UILabel *wordLabel;
@property(nonatomic, strong) UIButton *wordButton;
@property(nonatomic, copy) NSString *touchWord;

@end

@implementation XZCardView

//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        [self setup];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setupLayer];
        [self setUpButton];
        [self addSubview:self.wordButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.wordButton.frame = CGRectMake(10,0,self.layer.frame.size.width-10,self.layer.frame.size.height);
}

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self setup];
//    }
//    return self;
//}

- (void)setupLayer {
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
    self.layer.backgroundColor = [UIColor colorWithRed:102 green:204 blue:255 alpha:1].CGColor;
}

- (void)setUpButton {
    self.wordButton = [[UIButton alloc]init];
    self.wordButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:40];
    self.wordButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.wordButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.wordButton.titleLabel.numberOfLines = 0;
    [self.wordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [self.wordButton addTarget:self action:@selector(touchDown) forControlEvents: UIControlEventTouchUpInside];
}

- (void)touchDown {
    [self.delegate showMeaningWebview:self];
}

- (void)setUpLabel {
    self.wordLabel = [[UILabel alloc]init];
    self.wordLabel.font = [UIFont fontWithName:@"Arial" size:40];
    self.wordLabel.textAlignment = NSTextAlignmentCenter;
    self.wordLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.wordLabel.numberOfLines = 0;
//    self.wordLabel.backgroundColor = [UIColor orangeColor];
}

- (void)setLabel:(NSString *)note {
//    self.wordLabel.text = note;
    [self.wordButton setTitle:note forState:UIControlStateNormal];
}

@end
