//
//  WBXMLViewController.m
//  WBDemo
//
//  Created by GM on 17/3/12.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBXMLViewController.h"
#import "WBModelManager.h"
#import "WBControlModel.h"
#import "UIView+WBCreat.h"
#import "UIView+Frame.h"
#import "WBSocketManager.h"
#import "DMTimer.h"
#import "WBGroupCommand.h"
#import <SVProgressHUD.h>

#define KEmptySimpleCommond @"0"
#define KEmptyComplexCommond @"none"
@interface WBXMLViewController ()

@property (nonatomic, strong) WBControlModel *controlModel;
@property (nonatomic, strong) UIView * currentXMLView;
@property (nonatomic, strong) NSMutableArray * selectBtns;

@end

@implementation WBXMLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.controlModel = [[WBModelManager sharedInstance] controlModelAtIndex:_pageIndex];
    self.currentXMLView = [self loadCustomViewWithModel:_controlModel];
    [self.view addSubview:self.currentXMLView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[WBSocketManager sharedInstance] udpStopMonotor];
}


- (void)encodeData:(NSData *)data {
    for (NSInteger i = 1; i < 16; i ++) {
        NSString * result = [[NSString alloc] initWithData:data encoding:i];
        NSLog(@"result : %@",result);
    }
}

- (UIView *)loadCustomViewWithModel:(WBControlModel *)controlModel {
    UIView * containerView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self configControllerView:containerView withModel:controlModel];
    for (NSInteger i = controlModel.subModels.count - 1; i >= 0 ; i--) {
        WBBaseObject * object = controlModel.subModels[i];
        object.controlPageSize = controlModel.PageSize;
        UIView * subView = [UIView createViewWithModel:object];
        if ([subView isKindOfClass:[UIButton class]]) {
            WBButton * button = (WBButton *)subView;
            [self addSelectorForButton:button withButtonModel:(WBButtonModel *)object];
        }
        [containerView addSubview:subView];
    }
    return containerView;
}

- (void)configControllerView:(UIView *)containerView withModel:(WBControlModel *)controlModel {

    if (controlModel.mUpImage) {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = [UIImage imageWithData:controlModel.mUpImage];
        [containerView addSubview:imageView];
    }
}

- (void)addSelectorForButton:(WBButton *)button withButtonModel:(WBButtonModel *)buttonModel {

    NSString * pageName = buttonModel.pageName;
    if (pageName.length != 0) {
        //添加跳转页面的逻辑
        [button addTarget:self action:@selector(pageForward:) forControlEvents:UIControlEventTouchUpInside];
        //有页面跳转的按钮也会有发送指令的事件
        if(![buttonModel.CommandButtonUp isEqualToString:KEmptySimpleCommond]) {
            [button addTarget:self action:@selector(actionForUp:) forControlEvents:UIControlEventTouchUpInside];
        } else if (![buttonModel.CommandButtonDown isEqualToString:KEmptySimpleCommond]) {
            [button addTarget:self action:@selector(actionForDown:) forControlEvents:UIControlEventTouchDown];
        }
    } else if(![buttonModel.CommandButtonUp isEqualToString:KEmptySimpleCommond]){
        //button弹起指令
        [button addTarget:self action:@selector(actionForUp:) forControlEvents:UIControlEventTouchUpInside];
    } else if (![buttonModel.CommandButtonDown isEqualToString:KEmptySimpleCommond]) {
        //button按下指令 复合指令
        NSString * variableName = button.buttonModel.VariableName;
        if ([variableName isEqualToString:@"0"] || [variableName isEqualToString:@"none"]) {
            [button addTarget:self action:@selector(actionForUp:) forControlEvents:UIControlEventTouchUpInside];
        }
        [button addTarget:self action:@selector(actionForDown:) forControlEvents:UIControlEventTouchDown];
    }
    [button addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchCancel];
}

#pragma mark - ButtonAction

- (void)actionCancel:(WBButton *)button {
    [[DMTimer sharedInstance] cancelTimerWithName:[self timerNameForButton:button]];
    [[WBSocketManager sharedInstance] repeatMessageSendFinish];
    [self.selectBtns removeObject:button];
}

- (void)actionForUp:(WBButton *)button {
    NSString * commond = button.buttonModel.CommandButtonUp;
    [[WBSocketManager sharedInstance] updSendOrder:commond machineName:button.buttonModel.CenterControlName];
    [[DMTimer sharedInstance] cancelTimerWithName:[self timerNameForButton:button]];
    [[WBSocketManager sharedInstance] repeatMessageSendFinish];
    for (UIButton * btn in self.selectBtns) {
        btn.selected = false;
    }
    [self.selectBtns removeObject:button];
}

- (void)actionForDown:(WBButton *)button {

    NSString * commond = button.buttonModel.CommandButtonDown;
    NSString * variableName = button.buttonModel.VariableName;

    //循环指令测试

    if ([variableName isEqualToString:@"0"] || [variableName isEqualToString:@"none"]) {
        //非复合按钮
        double time = [button.buttonModel.CommandButtonPressedDelay doubleValue] / 1000;
        if (self.selectBtns.count > 0) {
            for (UIButton * button in self.selectBtns) {
                button.selected = false;
            }
            [self.selectBtns removeAllObjects];
        }

        if (time == 0) {
            [[WBSocketManager sharedInstance] updSendOrder:commond machineName:button.buttonModel.CenterControlName];
        } else {
            //循环指令
            [[WBSocketManager sharedInstance] updSendOrder:commond machineName:button.buttonModel.CenterControlName];
            NSString * timerName = [self timerNameForButton:button];
            static NSInteger count = 0;
            [[DMTimer sharedInstance] scheduleDispatchTimerName:timerName timeInterval:time queue:dispatch_get_main_queue() repeats:true action:^{
//                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"时间间隔 ： %f  循环次数： %ld",time,(long)count]];
                [[WBSocketManager sharedInstance] sendSessionCommand:commond machineName:button.buttonModel.CenterControlName];
                count ++;
            }];
        }
    } else if ([variableName isEqualToString:@"X1"]){
        //复合按钮
        [[WBGroupCommand sharedInstance] setInChannel:button.buttonModel.dataValue];
        [[WBGroupCommand sharedInstance] setGetMatrixtype:button.buttonModel.VariableType];
        if (self.selectBtns.count == 0) {
            //按下第一个复合按钮
            [button setSelected:true];
            [self.selectBtns addObject:button];

        } else if (self.selectBtns.count == 1) {
            //按下第二个复合按钮

            if (self.selectBtns.count >= 1) {
                WBButton * btn = self.selectBtns[0];
                if ([btn.buttonModel.VariableName isEqualToString:@"X1"]) {
                    if ([btn isEqual:button]) {
                        [self.selectBtns removeAllObjects];
                        [button setSelected:false];
                    } else {
                        [self.selectBtns removeAllObjects];
                        [self.selectBtns addObject:button];
                        [button setSelected:true];
                        [btn setSelected:false];
                        return;
                    }
                }
            }
            for (UIButton * btn in self.selectBtns) {
                btn.selected = false;
            }
            [self.selectBtns removeAllObjects];
            [[WBSocketManager sharedInstance] updSendOrder:commond machineName:button.buttonModel.CenterControlName isGroupCommand:true];
        }
    } else if ([variableName isEqualToString:@"X2"]) {
        [[WBGroupCommand sharedInstance] setOutChannel:button.buttonModel.dataValue];
        [[WBGroupCommand sharedInstance] setGetMatrixtype:button.buttonModel.VariableType];
        if (self.selectBtns.count == 0) {
            //按下第一个复合按钮
            [button setSelected:true];
            [self.selectBtns addObject:button];

        } else if (self.selectBtns.count == 1) {
            //按下第二个复合按钮

            if (self.selectBtns.count >= 1) {
                WBButton * btn = self.selectBtns[0];
                if ([btn.buttonModel.VariableName isEqualToString:@"X2"]) {
                    if ([btn isEqual:button]) {
                        [self.selectBtns removeAllObjects];
                        [button setSelected:false];
                    } else {
                        [self.selectBtns removeAllObjects];
                        [self.selectBtns addObject:button];
                        [button setSelected:true];
                        [btn setSelected:false];
                        return;
                    }
                }
            }

            for (UIButton * btn in self.selectBtns) {
                btn.selected = false;
            }
            [self.selectBtns removeAllObjects];
            [[WBSocketManager sharedInstance] updSendOrder:commond machineName:button.buttonModel.CenterControlName isGroupCommand:true];
        }
    }
}

- (void)pageForward:(WBButton *)button {
    [self pushWithPageIndex:button.buttonModel.pageName];
}

- (void)pushWithPageIndex:(NSString *)pageName {

    if (pageName.length == 0) {
        return;
    }
    NSInteger pageIndex = [pageName integerValue] - 1;

    if (pageIndex == self.pageIndex || pageIndex < 0) {
        return;
    }
    [self.selectBtns removeAllObjects];
    WBControlModel * model = [[WBModelManager sharedInstance] controlModelAtIndex:pageIndex];
    if (!model) {
        return;
    }
    UIView * containerView = [self loadCustomViewWithModel:model];
    containerView.frame = self.currentXMLView.frame;
    [self.view addSubview:containerView];
    [self.currentXMLView removeFromSuperview];
    self.currentXMLView = containerView;
    self.pageIndex = pageIndex;

}

- (NSString *)timerNameForButton:(WBButton *)button {

    NSString * text = button.titleLabel.text;
    NSString * varName = button.buttonModel.VariableName;
    NSString * varType = button.buttonModel.VariableType;
    NSString * timerName = [NSString stringWithFormat:@"%@_%@_%@",text,varName,varType];
    return timerName;
}

#pragma mark - Get 
- (NSMutableArray *)selectBtns {
    if (!_selectBtns) {
        _selectBtns = [NSMutableArray array];
    }
    return _selectBtns;
}

@end
