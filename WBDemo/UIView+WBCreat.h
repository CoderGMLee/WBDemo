//
//  UIView+WBCreat.h
//  WBDemo
//
//  Created by GM on 17/3/8.
//  Copyright © 2017年 GM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBButtonModel.h"
#import "WBTextViewModel.h"
#import "WBImageViewModel.h"
#import "WBButton.h"
@interface UIView (WBCreat)

+ (UIView *)createViewWithModel:(WBBaseObject *)model;

+ (WBButton *)createButtonWithModel:(WBButtonModel *)model;

+ (UILabel *)createLabelWithModel:(WBTextViewModel *)model;

+ (UIImageView *)createImageViewWithModel:(WBImageViewModel *)model;

@end
