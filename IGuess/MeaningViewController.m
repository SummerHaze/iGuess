//
//  MeaningViewController.m
//  IGuess
//
//  Created by xia on 8/25/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import "MeaningViewController.h"

@interface MeaningViewController ()

@end

@implementation MeaningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIWebView *webView = [[UIWebView alloc]initWithFrame:bounds];
    
    webView.scalesPageToFit = YES;
    webView.autoresizesSubviews = NO;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    [self.view addSubview: webView];
    
//    NSString *encodingString = [self.name stringByAddingPercentEncodingWithAllowedCharacters:controlCharacterSet];
    NSString *encodingString = [self.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://baike.baidu.com/item/%@", encodingString];
    DDLogDebug(@"request url is: %@", urlString);
    
    NSURL *url = [NSURL URLWithString: urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
