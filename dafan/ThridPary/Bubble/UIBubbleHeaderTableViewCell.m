//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"

@interface UIBubbleHeaderTableViewCell ()

@property (nonatomic, retain) UILabel *label;
@property(nonatomic, strong) UIImageView* clockBgImageView;

@end

@implementation UIBubbleHeaderTableViewCell

+ (CGFloat)height
{
    return 28.0;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    self.backgroundColor=[UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, [UIBubbleHeaderTableViewCell height])];
    
    self.label.font = [UIFont boldSystemFontOfSize:9];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.label];
    
    UIImage* image = [[UIImage imageNamed:@"msg_section_header_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 5) resizingMode:UIImageResizingModeStretch];
    self.clockBgImageView = [[UIImageView alloc] initWithImage:image];
    self.clockBgImageView.frame = CGRectMake(0, 0, 80, 14);
    [self.contentView addSubview:self.clockBgImageView];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    self.clockBgImageView.center = CGPointMake(size.width / 2 , size.height / 2);
    self.label.center = self.clockBgImageView.center;
    
}

@synthesize label = _label;


- (void) setDateString:(NSString *)dateString
{
    self.label.text = dateString;
}



@end
