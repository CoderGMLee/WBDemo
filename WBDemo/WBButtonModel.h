//
//  WBButtonModel.h
//  WBDemo
//
//  Created by GM on 17/3/7.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBBaseObject.h"

@interface WBButtonModel : WBBaseObject

@property (nonatomic, copy) NSString * mText;
@property (nonatomic, copy) NSString * mTextAlign;
@property (nonatomic, copy) NSString * mSize;
@property (nonatomic, copy) NSString * mLocation;
@property (nonatomic, strong)NSData * mDownImage;
@property (nonatomic, strong)NSData * mUpImage;
@property (nonatomic, copy) NSString * DownImagePath;
@property (nonatomic, copy) NSString * UpImagePath;
@property (nonatomic, copy) NSString * mForeColorRgb;
@property (nonatomic, copy) NSString * mForeColorArgb;
@property (nonatomic, copy) NSString * mForeColor;
@property (nonatomic, copy) NSString * mFontSize;

/**
 响应中控机的名称
 */
@property (nonatomic, copy) NSString * CenterControlName;
@property (nonatomic, copy) NSString * CommandButtonDown;
@property (nonatomic, copy) NSString * CommandButtonUp;
@property (nonatomic, copy) NSString * CommandButtonPressedDelay;

/**
 跳转至其它页面
 */
@property (nonatomic, copy) NSString * pageName;


/**
 X1：输入 matrix_source.setMatrix_source(1);//设置为输入源
 X2 :输出 matrix_source.setMatrix_source(2);//设置为输出源
 matrix_source.setMatrix_source(0);//设置为普通按键，非矩阵
 */
@property (nonatomic, copy) NSString * VariableName;

/**
 HEX 输入  ASCII输出
 矩阵的数据类型，是十六进制，还是ASCII码
 matrix_data_type.setMatrix_data_type(0);//设置为输入源 HEX
 matrix_data_type.setMatrix_data_type(1);//设置为输出源 ASCII
 */
@property (nonatomic, copy) NSString * VariableType;

/**
 矩阵输入输出通道的值 x y
 */
@property (nonatomic, copy) NSString * VariableValue;
@property (nonatomic, copy) NSString * VariableGroup;

@property (nonatomic, copy) NSString * dataValue;


@end
