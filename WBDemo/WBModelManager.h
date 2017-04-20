//
//  WBModelManager.h
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBImageViewModel.h"
#import "WBTextViewModel.h"
#import "WBButtonModel.h"
#import "WBControlModel.h"


@interface WBModelManager : NSObject

+ (WBModelManager *)sharedInstance;

- (void)addControllerModel:(WBControlModel *)model;

- (WBControlModel *)controlModelAtIndex:(NSInteger)index;

- (void)clearAll;
@end
