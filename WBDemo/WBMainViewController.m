//
//  WBMainViewController.m
//  WBDemo
//
//  Created by GM on 17/3/12.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBMainViewController.h"
#import "WBMainContainerView.h"
#import "WBSocketManager.h"
#import "CommonHeader.h"
#import "WBXMLViewController.h"
#import "WBParse.h"
#import "WBFileManager.h"
#import "WBStartView.h"

@interface WBMainViewController ()<WBMainViewDelegate>

@property (nonatomic, strong) WBMainContainerView * mainView;
@property (nonatomic, strong) WBStartView * startBGView;



@end

@implementation WBMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = true;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseCompleteHandle:) name:KNotiParseComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(parseErrorHandle:) name:KNotiParseError object:nil];
    self.startBGView = [[NSBundle mainBundle] loadNibNamed:@"WBStartView" owner:nil options:nil][0];
    self.startBGView.frame = self.view.bounds;
    [self.view addSubview:self.startBGView];

//    if ([[WBFileManager sharedInstance] hasXMLFile]) {
//        NSData * data = [[WBFileManager sharedInstance] getXMLFile];
//        [[WBSocketManager sharedInstance] downloadComplete:data];
//        [self.startBGView setHidden:true];
//    } else {
//        self.mainView = [[NSBundle mainBundle] loadNibNamed:@"WBMainContainerView" owner:nil options:nil][0];
//        self.mainView.frame = self.view.bounds;
//        self.mainView.delegate = self;
//        [self.view addSubview:self.mainView];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[WBSocketManager sharedInstance] udpStartMonitor];
//        });
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[WBSocketManager sharedInstance] scanOther];
//    });


//    测试数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString * resourcePath = [[NSBundle mainBundle] pathForResource:@"download" ofType:@"xml"];
        NSData * data = [[NSData alloc] initWithContentsOfFile:resourcePath];
        [[WBSocketManager sharedInstance] downloadComplete:data];
    });
}

- (void)volumDidChnage {
    self.mainView = [[NSBundle mainBundle] loadNibNamed:@"WBMainContainerView" owner:nil options:nil][0];
    self.mainView.frame = self.view.bounds;
    self.mainView.delegate = self;
    [self.view addSubview:self.mainView];
    [[WBSocketManager sharedInstance] udpStartMonitor];
    [[WBSocketManager sharedInstance] scanOther];
}

#pragma mark - NotificationHandle
- (void)parseCompleteHandle:(NSNotification *)noti {
    WBXMLViewController * vc = [[WBXMLViewController alloc] init];
    vc.pageIndex = 0;
    [self.navigationController pushViewController:vc animated:false];
}

- (void)parseErrorHandle:(NSNotification *)noti {
    [[WBFileManager sharedInstance] clear];
    self.mainView = [[NSBundle mainBundle] loadNibNamed:@"WBMainContainerView" owner:nil options:nil][0];
    self.mainView.frame = self.view.bounds;
    [self.view addSubview:self.mainView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[WBSocketManager sharedInstance] udpStartMonitor];
    });
}

#pragma mark - WBMainViewDelegate
- (void)backButtonClick {
    if ([[WBFileManager sharedInstance] hasXMLFile]) {
        NSData * data = [[WBFileManager sharedInstance] getXMLFile];
        [[WBSocketManager sharedInstance] downloadComplete:data];
        [self.startBGView setHidden:true];
    }
}
@end
