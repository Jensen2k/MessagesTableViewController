//
//  JSMessagesViewController+Attachment.m
//  JSMessagesDemo
//
//  Created by Martin Jensen on 16.02.14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSMessagesViewController+Attachment.h"
#import "JSMessage.h"
#import "JSBubbleAttachmentMessageCell.h"
#import <objc/runtime.h>


@implementation JSMessagesViewController (Attachment)


- (CGFloat)swizzled_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<JSMessageData> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    UIImageView *avatar = [self.dataSource avatarImageViewForRowAtIndexPath:indexPath sender:[message sender]];
    
    if ([message messageType] == JSMessageTypeText) {
        return [JSBubbleMessageCell neededHeightForBubbleMessageCellWithMessage:message
                                                                         avatar:avatar != nil];
    } else {
        return [JSBubbleAttachmentMessageCell neededHeightForBubbleMessageCellWithMessage:message
                                                                         avatar:avatar != nil];
    }
    
}

- (UITableViewCell *)swizzled_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Check if this is a position where we should show a loading cell
    BOOL shouldDisplayLoadingCell = [self.delegate shouldDisplayLoadingCellForRowAtIndexPath:indexPath];
    if (shouldDisplayLoadingCell) {
        UITableViewCell *loadingCell = [self.delegate loadingCellForRowAtIndexPath:indexPath];
        
        return loadingCell;
        
    }
    
    JSBubbleMessageType type = [self.delegate messageTypeForRowAtIndexPath:indexPath];
    
    UIImageView *bubbleImageView = [self.delegate bubbleImageViewWithType:type
                                                        forRowAtIndexPath:indexPath];
    
    id<JSMessageData> message = [self.dataSource messageForRowAtIndexPath:indexPath];
    
    UIImageView *avatar = [self.dataSource avatarImageViewForRowAtIndexPath:indexPath sender:[message sender]];
    
    BOOL displayTimestamp = YES;
    if ([self.delegate respondsToSelector:@selector(shouldDisplayTimestampForRowAtIndexPath:)]) {
        displayTimestamp = [self.delegate shouldDisplayTimestampForRowAtIndexPath:indexPath];
    }
    
    NSString *CellIdentifier = nil;
    if ([self.delegate respondsToSelector:@selector(customCellIdentifierForRowAtIndexPath:)]) {
        CellIdentifier = [self.delegate customCellIdentifierForRowAtIndexPath:indexPath];
    }
    
    if (!CellIdentifier) {
        CellIdentifier = [NSString stringWithFormat:@"JSMessageCell%d_%d_%d_%d_%d", (int)[message messageType], (int)type, displayTimestamp, avatar != nil, [message sender] != nil];
    }
    
    JSBubbleMessageCell *cell = (JSBubbleMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([message messageType] == JSMessageTypeText) {

    
        if (!cell) {
            cell = [[JSBubbleMessageCell alloc] initWithBubbleType:type
                                                   bubbleImageView:bubbleImageView
                                                           message:message
                                                 displaysTimestamp:displayTimestamp
                                                         hasAvatar:avatar != nil
                                                   reuseIdentifier:CellIdentifier];
        }
    

    } else {
        
        if (!cell) {
            cell = [[JSBubbleAttachmentMessageCell alloc] initWithBubbleType:type
                                                   bubbleImageView:bubbleImageView
                                                           message:message
                                                 displaysTimestamp:displayTimestamp
                                                         hasAvatar:avatar != nil
                                                   reuseIdentifier:CellIdentifier];
        }
        
        [((JSBubbleAttachmentView*)cell.bubbleView).tapGestureRecognizer setIndexPath:indexPath];
        [((JSBubbleAttachmentView*)cell.bubbleView).tapGestureRecognizer addTarget:self.delegate action:@selector(didSelectAttachmentAtIndexPath:)];
        NSLog(@"Self: %@", self);
    }

    [cell setMessage:message];
    [cell setAvatarImageView:avatar];
    [cell setBackgroundColor:tableView.backgroundColor];
    
    
#if TARGET_IPHONE_SIMULATOR
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeNone;
#else
    cell.bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
#endif
	
    if ([self.delegate respondsToSelector:@selector(configureCell:atIndexPath:)]) {
        [self.delegate configureCell:cell atIndexPath:indexPath];
    }
    

    return cell;
}

-(void)didSelectAttachmentAtIndexPath:(UIGestureRecognizer*)tap {
    
    NSLog(@"HELLO!");
    NSIndexPath *indexPath = ((JSBubbleTapGestureRecognizer*)tap).indexPath;
    
    //[self.delegate didSelectAttachmentAtIndexPath:indexPath];
}

+(void)load {
    
    /*
     *  cellForRowAtIndexPath
     */
    Method cellForRowOriginal, cellForRowSwizzle;
    cellForRowOriginal = class_getInstanceMethod(self, @selector(tableView:cellForRowAtIndexPath:));
    cellForRowSwizzle = class_getInstanceMethod(self, @selector(swizzled_tableView:cellForRowAtIndexPath:));
    method_exchangeImplementations(cellForRowOriginal, cellForRowSwizzle);
    
    /*
     * heightForRowAtIndexPath
     */
    Method heightForRowOriginal, heightForRowSwizzle;
    heightForRowOriginal = class_getInstanceMethod(self, @selector(tableView:heightForRowAtIndexPath:));
    heightForRowSwizzle = class_getInstanceMethod(self, @selector(swizzled_tableView:heightForRowAtIndexPath:));
    method_exchangeImplementations(heightForRowOriginal, heightForRowSwizzle);
    
}

@end
