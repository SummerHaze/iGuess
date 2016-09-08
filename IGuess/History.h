//
//  History.h
//  IGuess
//
//  Created by xia on 9/7/16.
//  Copyright © 2016 xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)sortResultsByRound;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSMutableArray *)countResults;

@end
