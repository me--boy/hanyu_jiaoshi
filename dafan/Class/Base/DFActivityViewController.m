//
//  DFActivityViewController.m
//  dafan
//
//  Created by iMac on 14-9-28.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFActivityViewController.h"
#import "DFColorDefine.h"

@interface DFActivityViewController ()

@property(nonatomic, strong) UITextView* contentTextView;
@property(nonatomic, strong) UIImageView* imageView;

@end

@implementation DFActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTextView];
    [self setContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initTextView
{
    CGRect navigationFrame = self.customNavigationBar.frame;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, -130, navigationFrame.size.width - 16, 115)];
    self.imageView.backgroundColor = [UIColor yellowColor];
    
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, navigationFrame.size.height, navigationFrame.size.width, self.view.frame.size.height - navigationFrame.size.height)];
    self.contentTextView.contentInset = UIEdgeInsetsMake(140, 8, 9, 8);
    [self.view addSubview:self.contentTextView];
    [self.contentTextView addSubview:self.imageView];
}

#define kSection0Content @"使零基础的学员初步掌握上海话，能进行日常的交流，能用上海话琉璃连贯地表达自己的想法和意愿。"
#define kSection1P0Content @"从基础语音和常用词汇开始，让学员掌握上海话发音技巧。"
#define kSection1P1Content @"对照文本教程，老师进行实时语音教学，1对1辅导和纠正学员发音。"
#define kSection1P2Content @"实战性的情景教学互动方式，模拟不同真实生活场景，提高学员实际会话能力。"
#define kSection2Content @"在上海经营事业的外地人士、公司白领、机关人员、销售人员、客服人员、窗口服务行业人员、在上海的外国朋友，以及生活需要用上海话的人士。"


- (void) setContent
{
    NSAttributedString* title0 = [self titleAttributeText:@"课程目标"];
    NSAttributedString* content0 = [self paragraphWithText:kSection0Content];
    
    NSAttributedString* title1 = [self titleAttributeText:@"课程特色"];
    NSAttributedString* section1Content0 = [self paragraphWithText:kSection1P0Content];
    NSAttributedString* section1Content1 = [self paragraphWithText:kSection1P1Content];
    NSAttributedString* section1Content2 = [self paragraphWithText:kSection1P2Content];
    
    NSAttributedString* title2 = [self titleAttributeText:@"目标学员"];
    NSAttributedString* content2 = [self paragraphWithText:kSection2Content];
    
    NSMutableAttributedString* content = [[NSMutableAttributedString alloc] initWithAttributedString:title0];
    [content appendAttributedString:content0];
    [content appendAttributedString:title1];
    [content appendAttributedString:section1Content0];
    [content appendAttributedString:section1Content1];
    [content appendAttributedString:section1Content2];
    [content appendAttributedString:title2];
    [content appendAttributedString:content2];
    
    self.contentTextView.attributedText = content;
}

- (NSAttributedString *) titleAttributeText:(NSString *)title
{
    NSMutableDictionary* parmas = [[NSMutableDictionary alloc] init];
    [parmas setObject:[UIFont systemFontOfSize:15] forKey:NSFontAttributeName];
    [parmas setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
    [parmas setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    [parmas setObject:[UIColor grayColor] forKey:NSUnderlineColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:title attributes:parmas];
}

- (NSAttributedString *) paragraphWithText:(NSString *)text
{
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 13;
    style.lineHeightMultiple = 1.5;
    style.alignment = NSTextAlignmentLeft;
    style.firstLineHeadIndent = 16;
    style.paragraphSpacing = 20;
    style.paragraphSpacingBefore = 12;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:style forKey:NSParagraphStyleAttributeName];
    [params setObject:RGBCOLOR(81, 81, 81) forKey:NSForegroundColorAttributeName];
    [params setObject:[UIFont systemFontOfSize:13] forKey:NSFontAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:params];
}


@end
