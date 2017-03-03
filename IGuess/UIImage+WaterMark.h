//
//  UIImage+WaterMark.h
//  IGuess
//
//  Created by xia on 10/28/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WaterMark)

+ (UIImage *)imageWithimage:(UIImage *)image content:(NSString *)content frame:(CGRect)frame;

@property (nonatomic, copy) NSString *str;

@end
