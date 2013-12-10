//
//  GEAppDelegate.m
//  Grouvent
//
//  Created by Blankwonder on 11/11/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEAppDelegate.h"
#import "GEStroageManager.h"
#import "NSData+Hex.h"
#import "NSString+MD5.h"
#import "GEChatModel.h"
#import "GEChatViewController.h"
#import "GEChatRoomListViewController.h"

static GEAppDelegate *SharedInstance;

@implementation GEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SharedInstance = self;
    KDXDebuggerInstallUncaughtExceptionHandler();
    KDXDebuggerSetLogPath([GEStroageManager sharedInstance].logPath);

    [self setupCustomUI];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.chatRoomListViewController = [[GEChatRoomListViewController alloc] initWithDefaultNibName];
    self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:self.chatRoomListViewController];
    self.window.rootViewController = self.rootNavigationController;
    [self.window makeKeyAndVisible];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(messageInsert:)
//                                                 name:GEPartyChatMessageInsertNotification
//                                               object:nil];

    return YES;
}
//
//- (void)messageInsert:(NSNotification *)notification {
//    ChatRoom *chatRoom = notification.object;
//
//    if (![notification.userInfo[@"type"] isEqualToString:GEChatModelInsertMessageNotificationTypeAppend]) {
//        return;
//    }
//
//    ChatMessage *message = notification.userInfo[@"message"];
//    if (!message) {
//        return;
//    }
//
//    if (![message.type isEqualToString:@"chat"]) {
//        return;
//    }
//
//    if ([GEChatViewController PartyChatViewControllerInView].chatRoom == chatRoom) {
//        KDXClassLog(@"Party chat view already presented, igrone.");
//        return;
//    }
//
//    GEAlertView *av = [[GEAlertView alloc] initWithTitle:@"消息"
//                                                 message:[NSString stringWithFormat:@"%@有新消息", chatRoom.title]
//                                       cancelButtonTitle:@"忽略"
//                                             cancelBlock:nil];
//
//    [av addButtonWithTitle:@"查看" actionBlock:^{
//        [self pushChatViewControllerWithChatRoom:chatRoom animated:YES];
//    }];
//
//    [av show];
//}
//


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[GEChatModel sharedInstance] disconnectAll];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (GEAppDelegate *)sharedInstance {
    return SharedInstance;
}

- (void)pushChatViewControllerWithChatRoom:(ChatRoom *)chatRoom animated:(BOOL)animated {
    GEChatViewController *vc = [[GEChatViewController alloc] initWithDefaultNibName];
    vc.chatRoom = chatRoom;
    [self.rootNavigationController pushViewController:vc animated:animated];
}

- (void)setupCustomUI {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageResourceNamed:@"nav_bar"]
                                       forBarMetrics:UIBarMetricsDefault];

    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    [barButtonItem setBackgroundImage:[[UIImage imageResourceNamed:@"nav_bar_normal_button"] stretchableImageWithLeftCapWidth:10 topCapHeight:0]
                             forState:UIControlStateNormal
                           barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackButtonBackgroundImage:[[UIImage imageResourceNamed:@"nav_bar_back_button"] stretchableImageWithLeftCapWidth:20 topCapHeight:0]
                                       forState:UIControlStateNormal
                                     barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(-3, 0)
                                          forBarMetrics:UIBarMetricsDefault];
}

- (void)setPredefinedNickname:(NSString *)predefinedNickname {
    [[NSUserDefaults standardUserDefaults] setObject:predefinedNickname forKey:GEUserDefaultsKeyUserPredefinedNickname];
}

- (NSString *)predefinedNickname {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GEUserDefaultsKeyUserPredefinedNickname];
}

@end
