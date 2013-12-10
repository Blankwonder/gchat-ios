//
//  GEChatRoomListViewController.h
//  GChat
//
//  Created by Blankwonder on 3/10/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface GEChatRoomListViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    IBOutlet UITableView *_tableView;
}

@end
