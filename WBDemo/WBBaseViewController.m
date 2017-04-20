//
//  WBBaseViewController.m
//  WBDemo
//
//  Created by GM on 17/3/13.
//  Copyright © 2017年 GM. All rights reserved.
//

#import "WBBaseViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WBParse.h"
#import "WBModelManager.h"
#import "WBSocketManager.h"
@interface WBBaseViewController ()

@end

@implementation WBBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initVolumeView];
    [self initAudioSession];
}


- (void)initAudioSession {
    NSError * error = nil;
    [[AVAudioSession sharedInstance] setActive:true error:&error];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)volumeChanged:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"AVSystemController_SystemVolumeDidChangeNotification"]) {
        NSDictionary * userInfo = notification.userInfo;
        NSString * reasonStr = userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
        if ([reasonStr isEqualToString:@"ExplicitVolumeChange"]) {
            //监听到音量改变
            if (![self.navigationController.topViewController isKindOfClass:NSClassFromString(@"WBMainViewController")]) {
                [self.navigationController popToRootViewControllerAnimated:true];
                [[WBModelManager sharedInstance] clearAll];
                [self volumDidChnage];
            }

        }
    }
}

- (void)volumDidChnage {

}

- (void)initVolumeView {
    MPVolumeView * volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-20, -20, 10, 10)];
    volumeView.hidden = false;
    [self.view addSubview:volumeView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return false;
} 

@end
