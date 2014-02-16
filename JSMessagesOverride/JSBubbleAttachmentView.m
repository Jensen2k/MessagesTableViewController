//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleAttachmentView.h"

#import "JSMessageInputView.h"
#import "JSAvatarImageFactory.h"
#import "NSString+JSMessagesView.h"

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f


@interface JSBubbleAttachmentView()

- (void)setup;

- (void)addTextViewObservers;
- (void)removeTextViewObservers;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)neededSizeForText:(NSString *)text;
+ (CGFloat)neededHeightForText:(NSString *)text;

@end


@implementation JSBubbleAttachmentView

@synthesize type = _type;
@synthesize bubbleImageView = _bubbleImageView;
@synthesize textView = _textView;

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        _type = bubleType;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        [self addSubview:imageView];
        [self bringSubviewToFront:imageView];
        _attachmentImageView = imageView;
        
        _tapGestureRecognizer = [[JSBubbleTapGestureRecognizer alloc] init];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [_attachmentImageView addGestureRecognizer:_tapGestureRecognizer];
        
//        NOTE: TODO: textView frame & text inset
//        --------------------
//        future implementation for textView frame
//        in layoutSubviews : "self.textView.frame = textFrame;" is not needed
//        when setting the property : "_textView.textContainerInset = UIEdgeInsetsZero;"
//        unfortunately, this API is available in iOS 7.0+
//        update after dropping support for iOS 6.0
//        --------------------
    }
    return self;
}

- (void)dealloc
{
    _bubbleImageView = nil;
    _attachmentImageView = nil;
}


#pragma mark - Getters

- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [JSBubbleAttachmentView neededSizeForImageView:self.attachmentImageView];
    
    return CGRectIntegral(CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                                     kMarginTop,
                                     bubbleSize.width,
                                     bubbleSize.height + kMarginTop));
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bubbleImageView.frame = [self bubbleFrame];
    
    CGFloat textX = self.bubbleImageView.frame.origin.x;
    
    if (self.type == JSBubbleMessageTypeIncoming) {
        textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
    }
    
    CGRect textFrame = CGRectMake(textX,
                                  self.bubbleImageView.frame.origin.y,
                                  self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f),
                                  self.bubbleImageView.frame.size.height - kMarginTop);
    
    self.attachmentImageView.frame = CGRectIntegral(textFrame);
}

#pragma mark - Bubble view


+ (CGSize)neededSizeForImageView:(UIImageView *)imageView
{
    CGSize imageSize = CGSizeMake(60, 60);
    
	return CGSizeMake(imageSize.width + kBubblePaddingRight,
                      imageSize.height + kPaddingTop + kPaddingBottom);
}


@end