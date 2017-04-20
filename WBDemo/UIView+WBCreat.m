//
//  UIView+WBCreat.m
//  WBDemo
//
//  Created by GM on 17/3/8.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "UIView+WBCreat.h"
#import "UIColor+DMExtension.h"
#import "UIView+Frame.h"
@implementation UIView (WBCreat)

#pragma mark - Create View

+ (UIView *)createViewWithModel:(WBBaseObject *)model {

    if ([model isKindOfClass:[WBButtonModel class]]) {
        return [self createButtonWithModel:(WBButtonModel *)model];
    } else if ([model isKindOfClass:[WBTextViewModel class]]) {
        return [self createLabelWithModel:(WBTextViewModel *)model];
    } else if ([model isKindOfClass:[WBImageViewModel class]]) {
        return [self createImageViewWithModel:(WBImageViewModel *)model];
    }
    return nil;
}


+ (WBButton *)createButtonWithModel:(WBButtonModel *)model {

    WBButton * button = [WBButton buttonWithType:UIButtonTypeCustom];
    button.buttonModel = model;
    button.frame = [self getFrame:model.mLocation sizeStr:model.mSize controlPageSize:model.controlPageSize];
    [button setTitle:model.mText forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:[self getTextAlignmentFromString:model.mTextAlign]];
    UIFont * font =[UIFont systemFontOfSize:[model.mFontSize floatValue] / 2];
    [button.titleLabel setFont:font];
    [button setTitleColor:[self getColorWithString:model.mForeColorArgb] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithData:model.mDownImage] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageWithData:model.mDownImage] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageWithData:model.mUpImage] forState:UIControlStateNormal];
    
    return button;
}

+ (UILabel *)createLabelWithModel:(WBTextViewModel *)model {
    UILabel * label = [[UILabel alloc] init];
    label.frame = [self getFrame:model.mLocation sizeStr:model.mSize controlPageSize:model.controlPageSize];
    label.font = [UIFont systemFontOfSize:[model.mFontSize floatValue] / 2];
    label.textAlignment = [self getTextAlignmentFromString:model.mTextAlign];
    label.textColor = [self getColorWithString:model.mForeColorArgb];
    label.backgroundColor = [self getColorWithString:model.mBackColorArgb];
    label.text = model.mText;
    return label;
}

+ (UIImageView *)createImageViewWithModel:(WBImageViewModel *)model {
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.frame = [self getFrame:model.mLocation sizeStr:model.mSize controlPageSize:model.controlPageSize];
    imageView.image = [UIImage imageWithData:model.mImage];
    imageView.backgroundColor = [UIColor colorWithString:model.mBackColorRgb];
    return imageView;
}

+ (CGRect)getFrame:(NSString *)locationStr sizeStr:(NSString *)sizeStr controlPageSize:(NSString *)pageSize{

    NSArray * locationArr = [locationStr componentsSeparatedByString:@","];
    NSArray * sizeArr = [sizeStr componentsSeparatedByString:@","];
    NSArray * controlSizeArr = [pageSize componentsSeparatedByString:@","];

    CGFloat x = 0 , y = 0 , width = 0, height = 0 , controlWid = 0, controlHei = 0, widRatio = 0, heiRatio = 0;
    if (locationArr.count == 2) {
        NSString * xString = locationArr[0];
        NSString * yString = locationArr[1];
        x = [xString floatValue] / 2;
        y = [yString floatValue] / 2;
    }
    if (sizeArr.count == 2) {
        NSString * widString = sizeArr[0];
        NSString * heiString = sizeArr[1];
        width = [widString floatValue] / 2;
        height = [heiString floatValue] / 2;
    }

    if (controlSizeArr.count == 2) {
        controlWid = [controlSizeArr[0] floatValue];
        controlHei = [controlSizeArr[1] floatValue];
    }

    widRatio = (SCREEN_WID * 2) / controlWid;
    heiRatio = (SCREEN_HEI * 2) / controlHei;

    return CGRectMake(x * widRatio, y * heiRatio, width * widRatio, height * heiRatio);
}

//+ (UIFont *)getFontForBaseFontNum:(NSString *)fontNum controlPageSize:(NSString *)pageSize modelSize:(NSString *)modelSize {
//
//    NSInteger baseFont = [fontNum integerValue];
//    NSArray * controlSizeArr = [pageSize componentsSeparatedByString:@","];
//    NSArray * sizeArr = [modelSize componentsSeparatedByString:@","];
//
//    CGFloat controlWid = 0, width = 0, height = 0, controlHei = 0, widRatio = 0, heiRatio = 0;
//    if (controlSizeArr.count == 2) {
//        controlWid = [controlSizeArr[0] floatValue];
//        controlHei = [controlSizeArr[1] floatValue];
//    }
//
//
//    if (sizeArr.count == 2) {
//        NSString * widString = sizeArr[0];
//        NSString * heiString = sizeArr[1];
//        width = [widString floatValue] / 2;
//        height = [heiString floatValue] / 2;
//    }
//
//    widRatio = (SCREEN_WID * 2) / controlWid;
//    heiRatio = (SCREEN_HEI * 2) / controlHei;
//
//    UIFont * font = [UIFont systemFontOfSize:baseFont * heiRatio];
//    return font;
//}

+ (NSTextAlignment)getTextAlignmentFromString:(NSString *)string {

    if ([string containsString:@"Center"]) {
        return NSTextAlignmentCenter;
    } else if ([string containsString:@"Left"]) {
        return NSTextAlignmentLeft;
    } else if ([string containsString:@"Right"]) {
        return NSTextAlignmentRight;
    }
    NSLog(@"TextAlignment 样式不匹配 ： %@",string);
    return NSTextAlignmentCenter;
}

+ (UIColor *)getColorWithString:(NSString *)colorString {

    UIColor * color = nil;
    NSArray * colorArray = [colorString componentsSeparatedByString:@"|"];
    if (colorArray.count == 4) {
        NSInteger red = [colorArray[1] integerValue];
        NSInteger green = [colorArray[2] integerValue];
        NSInteger blue = [colorArray[3] integerValue];
        NSInteger alpha = [colorArray[0] integerValue];
        color = [UIColor colorWithR:red g:green b:blue alpha:alpha];
    } else {
        NSLog(@"色值数据解析error %ld",colorArray.count);
    }
    return color;
}

@end
