//
//  WBImageViewModel.h
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBBaseObject.h"

@interface WBImageViewModel : WBBaseObject
@property (nonatomic, copy) NSString * mSize;
@property (nonatomic, copy) NSString * mLocation;
@property (nonatomic, copy) NSString * mBackColorRgb;
@property (nonatomic, copy) NSString * mBackColor;
@property (nonatomic, strong) NSData * mImage;
@property (nonatomic, copy) NSString * imagePath;
@end
