//
//  DFSectionVoiceTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFRepeatPanel.h"

#define kSectionVoiceTableCellDialectFontSize 14.f
#define kSectionVoiceTableCellMandarinFontSize 12.f

@interface DFSectionVoiceTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *dialectLabel;
@property (strong, nonatomic) UILabel *mandarinLabel;

@property(nonatomic) CGSize dialectSize;
@property(nonatomic) CGSize mandarinSize;

@property(nonatomic) UIEdgeInsets contentInsets;
@property(nonatomic) CGFloat labelSpace;

@property(nonatomic, strong) DFRepeatPanel* repeatPanel;

@end
