//
//  ViewController.m
//  WBDemo
//
//  Created by GM on 17/2/16.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "WBParse.h"
#import "WBControlModel.h"
#import "WBModelManager.h"
#import "UIView+WBCreat.h"
#import "WBSocketManager.h"
#import "CommonHeader.h"
@interface ViewController ()

@property (nonatomic, strong) WBControlModel * controlModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseCompleteHandle:) name:KNotiParseComplete object:nil];
    // Do any additional setup after loading the view, typically from a nib.

    self.view.backgroundColor = [UIColor whiteColor];
    
    [WBParse parse];
    [self loadCustomView];
}

- (void)loadCustomView {

    self.controlModel = [[WBModelManager sharedInstance] controlModelAtIndex:0];
    for (WBBaseObject * object in self.controlModel.subModels) {
        UIView * subView = [UIView createViewWithModel:object];
        [self.view addSubview:subView];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NotificationHandle
- (void)parseCompleteHandle:(NSNotification *)noti {
    for (UIView * subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    [self loadCustomView];
}

@end
