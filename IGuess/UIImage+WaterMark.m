//
//  UIImage+WaterMark.m
//  IGuess
//
//  Created by xia on 10/28/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "UIImage+WaterMark.h"

@implementation UIImage (WaterMark)

+ (UIImage *)imageWithimage:(UIImage *)image content:(NSString *)content frame:(CGRect)frame {
    // 开启图形'上下文'
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    // 绘制原生图片
    [image drawAtPoint:CGPointZero];
    // 在原生图上绘制文字
    NSString *str = content;
    // 创建文字属性字典
    NSDictionary *dictionary = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:20]};
    // 绘制文字属性
    [str drawInRect:frame withAttributes:dictionary];
    // 从当前上下文获取修改后的图片
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    // 结束图形上下文
    UIGraphicsEndImageContext();
    
    return imageNew;
}

@end
