//
//  GEChatRoomListViewController.m
//  GChat
//
//  Created by Blankwonder on 3/10/13.
//  Copyright (c) 2013 Suixing Tech. All rights reserved.
//

#import "GEChatRoomListViewController.h"
#import <MessageUI/MessageUI.h>

@interface GEChatRoomListViewController ()

@end

@implementation GEChatRoomListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(setNickname)];
    self.navigationItem.title = @"Chatroom List";

    NSManagedObjectContext *context = [[GEChatModel sharedInstance].dataContext context_MainThread];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatRoom"
                                        inManagedObjectContext:context]];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"joinDate"
                                                                   ascending:YES
                                                                    selector:nil];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];

    NSError *error = nil;
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:context
                                 sectionNameKeyPath:nil
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    if (![_fetchedResultsController performFetch:&error]) {
        KDXClassLog(@"Error occered when perform fetch %@, %@", error, [error localizedDescription]);
    }
    KDXClassLog(@"Chat room count: %d", _fetchedResultsController.fetchedObjects.count);
}

- (void)addButtonPressed {
    if (!KDXUtilIsStringValid([GEAppDelegate sharedInstance].predefinedNickname)) {
        [self setNickname];
        return;
    }
    
    GEActionSheet *as = [[GEActionSheet alloc] initWithTitle:nil cancelButtonTitle:@"取消" cancelActionBlock:nil destructiveButtonTitle:nil destructiveActionBlock:nil];
    [as addButtonWithTitle:@"Create new chatroom" actionBlock:^{
        [self addNewParty];
    }];
    [as addButtonWithTitle:@"Join exist chatroom" actionBlock:^{
        [self joinExistParty];
    }];
    [as showInView:self.view];
}

- (void)addNewParty {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Title"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Done", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [av textFieldAtIndex:0];
    textField.placeholder = @"Input chatroom title";
    av.tag = 1;
    [av show];
}

- (void)joinExistParty {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Chatroom ID"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Done", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [av textFieldAtIndex:0];
    textField.placeholder = @"Input chatroom ID";
    av.tag = 2;
    [av show];
}

- (void)setNickname {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Predefine Nickname"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Done", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [av textFieldAtIndex:0];
    textField.placeholder = @"Nickname";
    av.tag = 3;
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSString *text = [[alertView textFieldAtIndex:0] text];
        if (text.length != 0) {
            if (alertView.tag == 1) {
                [self createNewChatRoomWithTitle:text];
            } else if (alertView.tag == 2) {
                [self joinExistChatroomWithID:text];
            } else if (alertView.tag == 3) {
                [[GEAppDelegate sharedInstance] setPredefinedNickname:text];
            }
        }
    }
}

- (void)joinExistChatroomWithID:(NSString *)roomId {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = nil;
    hud.detailsLabelText = nil;
    [hud show:NO];

    [[GEChatModel sharedInstance]
     joinExistChatroomWithRoomID:roomId
     nickname:[GEAppDelegate sharedInstance].predefinedNickname
     success:^{
        [hud hide:YES];
    } failure:^(NSError *error) {
        [hud hide:YES];
        GEAlertView *av = [[GEAlertView alloc] initWithTitle:GELocalizedString(@"ALERTVIEW_TITLE_ERROR", @"Error") message:error.localizedDescription cancelButtonTitle:@"OK" cancelBlock:nil];
        [av addButtonWithTitle:GELocalizedString(@"ALERTVIEW_BUTTON_RETRY", @"Retry") actionBlock:^{
            [self joinExistChatroomWithID:roomId];
        }];
        [av show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createNewChatRoomWithTitle:(NSString *)title {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = nil;
    hud.detailsLabelText = nil;
    [hud show:NO];

    [[GEChatModel sharedInstance]
     createNewChatRoomWithTitle:title
     sponsorNickname:[GEAppDelegate sharedInstance].predefinedNickname
     success:^(NSString *roomId, NSString *shortlink) {
         [hud hide:YES];
         GEAlertView *av = [[GEAlertView alloc] initWithTitle:@"Shortlink"
                                                      message:shortlink
                                            cancelButtonTitle:@"OK"
                                                  cancelBlock:nil];
         [av addButtonWithTitle:@"Send via SMS" actionBlock:^{

             MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
             vc.messageComposeDelegate = self;
             vc.body = shortlink;
             [self presentModalViewController:vc animated:YES];
         }];
         [av addButtonWithTitle:@"Send via Mail" actionBlock:^{
             MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
             vc.mailComposeDelegate = self;
             [vc setMessageBody:shortlink isHTML:NO];
             [self presentModalViewController:vc animated:YES];
         }];
         [av addButtonWithTitle:@"Copy" actionBlock:^{
             [[UIPasteboard generalPasteboard] setValue:shortlink forPasteboardType:(NSString *)kUTTypeUTF8PlainText];
         }];
         [av show];
     } failure:^(NSError *error) {
         [hud hide:YES];
         GEAlertView *av = [[GEAlertView alloc] initWithTitle:GELocalizedString(@"ALERTVIEW_TITLE_ERROR", @"Error") message:error.localizedDescription cancelButtonTitle:@"OK" cancelBlock:nil];
         [av addButtonWithTitle:GELocalizedString(@"ALERTVIEW_BUTTON_RETRY", @"Retry") actionBlock:^{
             [self createNewChatRoomWithTitle:title];
         }];
         [av show];
     }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatRoom *chatRoom = [_fetchedResultsController objectAtIndexPath:indexPath];

    NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = chatRoom.title;
    cell.detailTextLabel.text = chatRoom.shortlink;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatRoom *chatRoom = [_fetchedResultsController objectAtIndexPath:indexPath];
    [[GEAppDelegate sharedInstance] pushChatViewControllerWithChatRoom:chatRoom animated:YES];
}

@end
