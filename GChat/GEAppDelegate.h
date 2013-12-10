//
//  GEAppDelegate.h
//  Grouvent
//
//  Created by Blankwonder on 11/11/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GEChatRoomListViewController;

@interface GEAppDelegate : UIResponder <UIApplicationDelegate> {
}

+ (GEAppDelegate *)sharedInstance;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *rootNavigationController;
@property (strong, nonatomic) GEChatRoomListViewController *chatRoomListViewController;

- (void)pushChatViewControllerWithChatRoom:(ChatRoom *)chatRoom animated:(BOOL)animated;

@property (copy) NSString *predefinedNickname;

@end
