//
//  WBControlModel.h
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBBaseObject.h"

@interface WBControlModel : WBBaseObject

@property (nonatomic, copy) NSString * PageSize;
@property (nonatomic, copy) NSString * mBackColorRgb;
@property (nonatomic, copy) NSString * mBackColorArgb;
@property (nonatomic, copy) NSString * mBackColor;
@property (nonatomic, strong)NSData * mUpImage;

@property (nonatomic, strong)NSMutableArray * subModels;

@end
