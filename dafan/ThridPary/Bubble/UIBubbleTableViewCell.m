//
//  UIBubbleTableViewCell.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <QuartzCore/QuartzCore.h>
#import "UIBubbleTableViewCell.h"
#import "NSBubbleData.h"
#import "DFCommonImages.h"
#import "UIView+SYShape.h"
#import "UIImageView+WebCache.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIImageView *bubbleImage;
@property (nonatomic, strong) AsyncImageView *avatarImage;

@property(nonatomic, strong) UIView* trailView;

- (void) setupInternalData;

@end

@implementation UIBubbleTableViewCell

@synthesize data = _data;
@synthesize customView = _customView;
@synthesize bubbleImage = _bubbleImage;
@synthesize showAvatar = _showAvatar;
//@synthesize avatarImage = _avatarImage;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.avatarImage = [[AsyncImageView alloc] init];
        
        self.avatarImage.layer.cornerRadius = 2.0;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
        self.avatarImage.layer.borderWidth = 0.0f;
        [self addSubview:self.avatarImage];
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void) dealloc
{
    self.data = nil;
    self.customView = nil;
    self.bubbleImage = nil;
    self.avatarImage = nil;
    [super dealloc];
}
#endif

- (void)setDataInternal:(NSBubbleData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
#if !__has_feature(objc_arc)
        self.bubbleImage = [[[UIImageView alloc] init] autorelease];
#else
        self.bubbleImage = [[UIImageView alloc] init];
#endif
        [self addSubview:self.bubbleImage];
    }
    
    NSBubbleType type = self.data.type;
    
    CGFloat width = self.data.view.frame.size.width;
    CGFloat height = self.data.view.frame.size.height;

    CGFloat x = (type == BubbleTypeSomeoneElse) ? 0 : self.frame.size.width - width - self.data.insets.left - self.data.insets.right;
    CGFloat y = 0;
    self.backgroundColor=[UIColor clearColor];
    // Adjusting the x coordinate for avatar
    
    if (self.showAvatar)
    {
        [self.avatarImage setImageWithURL:self.data.avatar placeholderImage:[DFCommonImages defaultAvatarImage]];
        
        CGFloat avatarX = (type == BubbleTypeSomeoneElse) ? 2 : self.frame.size.width - 44;
        CGFloat avatarY = 2;
        
        self.avatarImage.frame = CGRectMake(avatarX, avatarY, 40, 40);
        [self.avatarImage circledWithColor:[UIColor grayColor] strokeWidth:1];
        
        
        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
        if (delta > 0) y = delta / 2;
        
        if (type == BubbleTypeSomeoneElse) x += 44;
        if (type == BubbleTypeMine) x -= 50;
    }

    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];

    [self.trailView removeFromSuperview];
    CGRect trailFrame = self.data.trailView.frame;
    self.trailView = self.data.trailView;
    if (self.trailView != nil)
    {
        trailFrame.size.height = self.frame.size.height;
        [self.contentView addSubview:self.trailView];
    }
    
    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = [[UIImage imageNamed:@"msg_bubble_somone.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 26, 14, 14) resizingMode:UIImageResizingModeStretch];
        trailFrame.origin.x = x + width + self.data.insets.left + self.data.insets.right + 8;
    }
    else {
        self.bubbleImage.image = [[UIImage imageNamed:@"msg_bubble_me.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 26) resizingMode:UIImageResizingModeStretch];
        trailFrame.origin.x = x - trailFrame.size.width - 8;
    }
    self.trailView.frame = trailFrame;

    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

@end
