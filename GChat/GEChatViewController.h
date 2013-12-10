//
//  GEPartyDetailViewController.h
//  Grouvent
//
//  Created by Blankwonder on 11/21/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEPartyChatTableView : UITableView

@end

@interface GEChatViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    IBOutlet UITableView *_tableView;
    IBOutlet UIView *_tableFrameView;
    IBOutlet UIView *_sendMessageView;

    IBOutlet UIImageView *_sendInputBoxBackground;
    IBOutlet UIView *_sendMessageTextInputWrapView;

    NSFetchedResultsController *_fetchedResultsController;

    BOOL _insertOccered;
}

+ (GEChatViewController *)PartyChatViewControllerInView;

- (IBAction)sendMessage;

@property ChatRoom *chatRoom;

@end