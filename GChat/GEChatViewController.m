//
//  GEPartyDetailViewController.m
//  Grouvent
//
//  Created by Blankwonder on 11/21/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "GEChatViewController.h"
#import "GEChatModel.h"
#import "GEChatMessageCell.h"
#import "HPGrowingTextView.h"
#import "NSDate+KDXFormatDate.h"
#import "GEChatSystemMessageCell.h"

@interface GEChatViewController () <HPGrowingTextViewDelegate> {
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    HPGrowingTextView *_messageTextView;
    UIView *_blackOverlayView;
    GEChatMessageCell *_titleCell;
    
    NSMutableArray *_avatarViews;
}

@end

@interface GEPartyChatTableViewDateHeaderView : UIView
@property (nonatomic) NSDate *date;
@end

@implementation GEPartyChatTableView

- (BOOL)allowsHeaderViewsToFloat {
    return NO;
}

@end

static GEChatViewController *PartyChatViewControllerInView = nil;
@implementation GEChatViewController

+ (GEChatViewController *)PartyChatViewControllerInView {
    return PartyChatViewControllerInView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized)];
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    _tapGestureRecognizer.enabled = NO;
    
    _messageTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(-1, -5, 240, 40)];
    _messageTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	_messageTextView.minNumberOfLines = 1;
	_messageTextView.maxNumberOfLines = 3;
	_messageTextView.returnKeyType = UIReturnKeySend;
	_messageTextView.font = [UIFont systemFontOfSize:14.0f];
	_messageTextView.delegate = self;
    _messageTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _messageTextView.backgroundColor = [UIColor clearColor];
    [_sendMessageTextInputWrapView addSubview:_messageTextView];

    _sendInputBoxBackground.image = [_sendInputBoxBackground.image stretchableImageWithLeftCapWidth:0 topCapHeight:22];

    self.navigationItem.title = self.chatRoom.title;

    NSManagedObjectContext *context = [[GEChatModel sharedInstance].dataContext context_MainThread];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ChatMessage"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"chatRoom = %@", self.chatRoom]];
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id"
                                                                   ascending:YES
                                                                    selector:nil];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];
    
    NSError *error = nil;
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                            initWithFetchRequest:fetchRequest
                                            managedObjectContext:context
                                            sectionNameKeyPath:@"sectionDate"
                                            cacheName:nil];
    _fetchedResultsController.delegate = self;
    if (![_fetchedResultsController performFetch:&error]) {
        KDXClassLog(@"Error occered when perform fetch %@, %@", error, [error localizedDescription]);
    }

    _tableView.delegate = self;
    _tableView.dataSource = self;

    [self resignActive];
}

- (void)resignActive {
    [[GEChatModel sharedInstance] connectChatRoom:self.chatRoom callback:^(BOOL success, NSError *error) {

    }];
    [[GEChatModel sharedInstance] syncPartyChatLog:self.chatRoom];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger section = [_tableView numberOfSections] - 1;
    if (section < 0)
        return;
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([_tableView numberOfRowsInSection:section] - 1) inSection:section];

    [_tableView scrollToRowAtIndexPath:scrollIndexPath
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_tableView reloadData];
    [self scrollToBottomAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSArray *chatMessages = [_fetchedResultsController fetchedObjects];
    if (chatMessages.count > 0) {
//        [[GEModelOperationManager sharedInstance] setParty:self.party
//                                         lastReadMessageID:[(ChatMessage *)[chatMessages lastObject] id]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PartyChatViewControllerInView = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    PartyChatViewControllerInView = nil;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
    _insertOccered = NO;
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
            _insertOccered = YES;
            break;
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
//            [self reconfigureCellAtIndexPath:indexPath];
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

    if (_insertOccered) {
        [self performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.1];
//        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Chat

- (IBAction)sendMessage {
    if (_messageTextView.text.length == 0)
        return;

    if ([[GEChatModel sharedInstance] isChatRoomConnected:self.chatRoom]) {
        [[GEChatModel sharedInstance] sendMessage:_messageTextView.text
                                         chatRoom:self.chatRoom];
        _messageTextView.text = nil;
    } else {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_tableFrameView];
        [_tableFrameView addSubview:hud];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = GELocalizedString(@"HUD_CONNECTING", @"正在连接..");
        hud.detailsLabelText = nil;
        [hud show:NO];
        [[GEChatModel sharedInstance]
         connectChatRoom:self.chatRoom
         callback:^(BOOL success, NSError *error) {
             if (success) {
                 [hud hide:YES];
                 [self sendMessage];
             } else {
                 [hud setFailStyle];
                 hud.labelText = GELocalizedString(@"HUD_CONNECTING_FAILURE", @"连接失败");
                 [hud hide:YES afterDelay:1.5];
             }
         }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([message.type isEqualToString:@"chat"]) {
        GEChatMessageCell *cell;
        
        if ([message.senderName isEqualToString:self.chatRoom.selfNickname]) {
            static NSString *CellIdentifierRight = @"MessageCellRight";
            cell = (GEChatMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierRight];
            if (!cell) {
                cell = [[GEChatMessageCell alloc] initWithChatMessageStyle:GEChatMessageCellStyleRight reuseIdentifier:CellIdentifierRight];
            }
        } else {
            static NSString *CellIdentifierLeft = @"MessageCellLeft";
            cell = (GEChatMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierLeft];
            if (!cell) {
                cell = [[GEChatMessageCell alloc] initWithChatMessageStyle:GEChatMessageCellStyleLeft reuseIdentifier:CellIdentifierLeft];
            }
        }
        cell.text = message.text;
        cell.sender = message.senderName;
        
        [cell setNeedsDisplay];
        
        return cell;
    } else {
        GEChatSystemMessageCell *cell;
        static NSString *CellIdentifier = @"GEChatSystemMessageCell";
        cell = (GEChatSystemMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GEChatSystemMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.text = [self systemMessageText:message];

        [cell setNeedsDisplay];
        return cell;
    }
}

- (NSString *)systemMessageText:(ChatMessage *)message {
    if ([message.type isEqualToString:@"join.party"]) {
        return [NSString stringWithFormat:@"%@接受了聚会邀请", message.senderName];
    } else if ([message.type isEqualToString:@"leave.party"]) {
        return [NSString stringWithFormat:@"%@拒绝了聚会邀请", message.senderName];
    } else if ([message.type isEqualToString:@"change.time"]) {
        NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:[message.text intValue]];
        return [NSString stringWithFormat:@"聚会的时间修改为%@", [newDate stringByMouthDayHourMinuteStyle]];
    } else if ([message.type isEqualToString:@"change.location"]) {
        return [NSString stringWithFormat:@"聚会的地点修改为%@", message.text];
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([message.type isEqualToString:@"chat"]) {
        return [GEChatMessageCell desiredHeightWithText:message.text];
    } else {
        return [GEChatSystemMessageCell desiredHeightWithText:[self systemMessageText:message]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GEPartyChatTableViewDateHeaderView *headerView = [[GEPartyChatTableViewDateHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
    headerView.backgroundColor = [UIColor clearColor];
    ChatMessage *message = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    headerView.date = message.date;
    return headerView;
}

- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (up) {
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, keyboardEndFrame.size.height, 0)];
    } else {
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    CGRect newFrame = _sendMessageView.frame;
    newFrame.origin.y = _tableFrameView.frame.size.height - _tableView.contentInset.bottom;
    _sendMessageView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:YES];
    [self scrollToBottomAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self moveTextViewForKeyboard:aNotification up:NO];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    _tapGestureRecognizer.enabled = YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    _tapGestureRecognizer.enabled = NO;
}

- (void)tapGestureRecognized {
    [self.view endEditing:NO];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = _sendMessageView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	_sendMessageView.frame = r;
    
    r = _tableFrameView.frame;
    r.size.height += diff;
	_tableFrameView.frame = r;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [self sendMessage];
    return YES;
}

@end


@implementation GEPartyChatTableViewDateHeaderView

- (void)drawRect:(CGRect)rect {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:kCFDateFormatterMediumStyle];
    NSString *str = [dateFormatter stringFromDate:self.date];
    CGSize size = [str sizeWithFont:font];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context
                                , CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:0.66].CGColor);

    [[UIColor colorWithRed:0.384314 green:0.384314 blue:0.384314 alpha:1.0] set];
    [str drawAtPoint:CGPointMake((self.bounds.size.width - size.width) / 2, 15) withFont:font];

    CGContextSetShadowWithColor(context
                                , CGSizeMake(0, 1), 0, [UIColor colorWithWhite:1 alpha:0.25].CGColor);
    CGContextSetLineWidth(context, 1);

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.780392 green:0.780392 blue:0.780392 alpha:1.0].CGColor);
    CGContextMoveToPoint(context, 10, 21);
    CGContextAddLineToPoint(context, (self.bounds.size.width - size.width) / 2 - 8, 21);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, self.bounds.size.width - 10, 21);
    CGContextAddLineToPoint(context, (self.bounds.size.width + size.width) / 2 + 8, 21);
    CGContextStrokePath(context);
}

@end