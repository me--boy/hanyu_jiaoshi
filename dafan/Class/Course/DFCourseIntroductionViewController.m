//
//  DFCourseIntroductionViewController.m
//  dafan
//
//  Created by iMac on 14-9-28.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseIntroductionViewController.h"
#import "DFColorDefine.h"
#import "UIImageView+WebCache.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFCommonImages.h"
#import "UIAlertView+SYExtension.h"

@interface DFCourseChapterTitleItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* topic;

@end

@implementation DFCourseChapterTitleItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.topic = [dictionary objectForKey:@"content"];
        self.title = [dictionary objectForKey:@"title"];
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@  %@", self.title, self.topic];
}

@end

@interface DFCourseIntroductionViewController () <UIAlertViewDelegate>

@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong) UIImageView* bannerImageView;

@property (nonatomic, weak)UILabel *teacherLabel;

@end

#define kMarginLeftRight 8
#define kMarginTopBottom 9
#define kTitleHeight 21

#define kChapterItemHeight 15

#define kSection0Content @"发音课程：20课时，基本掌握韩语发音，需要1个月；\n初级课程：80课时，掌握日常简单交流，需要6个月；\n中级课程：80课时，基本看懂一半韩剧，需要6个月；\n"

#define kSection1P0Content @"1. 韩语零基础同学；\n2. 计划去韩国留学的同学。\n"
//#define kSection1P1Content @"对照文本教程，老师进行实时语音教学，1对1辅导和纠正学员发音。"
//#define kSection1P2Content @"实战性的情景教学互动方式，模拟不同真实生活场景，提高学员实际会话能力。"
#define kSection2Content @"1. 能够与韩国人进行日常简单会话；\n2. 减少留学成本，缩短学语言时间，快速融入韩国文化；\n3. 掌握近5000词汇量、300多个语法知识；\n4. 达到韩国语能力考试TOPIK中级水平。\n"
#define kSection3Content @"韩通学院资深韩语讲师，天津外国语大学韩国语专业毕业，韩国语能力考试六级， 曽赴韩国中央大学学习，2009年开始从事韩国语网络教学工作，2011年开始在韩通韩国语学院中心进行面授教学， 网络授课与面授课教学经验丰富，韩语发音纯正，授课风格严谨不失幽默，知识点讲解深入浅出，清晰易懂，受到广大学员的喜欢。\n"
#define kSection4Content @"1. 作业批改\n2. 问题解答\n3. 语音复习课\n4. 班主任点对点跟踪\n5. 期末测评报告\n6. 课程复习讲义资料\n7. 一站式服务，免费指导材料，办签证 \n"
@implementation DFCourseIntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"课程介绍";
    [self initSubviews];
    
    [self requestDatas];
}

- (void) initSubviews
{
    CGSize size = self.view.frame.size;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationBar.frame.size.height, size.width, size.height - self.customNavigationBar.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentInset = UIEdgeInsetsMake(9, 8, 0, 8);
    [self.view addSubview:self.scrollView];
    
    //海报
    self.bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width - 2 * kMarginLeftRight, 115)];
//    self.bannerImageView.backgroundColor = [UIColor yellowColor];
    self.bannerImageView.clipsToBounds = YES;
    self.bannerImageView.image = [DFCommonImages defaultAvatarImage];
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.bannerImageView];
    
    //课程简介
    UIView* title0View = [self titleViewAtY:136.f title:@"课程简介"];
    [self.scrollView addSubview:title0View];
    
    UILabel* content0Label = [self paraphLabelAtY:title0View.frame.origin.y + title0View.frame.size.height content:kSection0Content];
    [self.scrollView addSubview:content0Label];
    
    //招生对象
    UIView* title1View = [self titleViewAtY:content0Label.frame.origin.y + content0Label.frame.size.height title:@"招生对象"];
    [self.scrollView addSubview:title1View];
    
    UILabel* content1P0Label = [self paraphLabelAtY:title1View.frame.origin.y + title1View.frame.size.height content:kSection1P0Content];
    [self.scrollView addSubview:content1P0Label];
    
    //学习效果
    UIView* title2View = [self titleViewAtY:content1P0Label.frame.origin.y + content1P0Label.frame.size.height title:@"学习效果"];
    [self.scrollView addSubview:title2View];
    
    UILabel* content2Label = [self paraphLabelAtY:title2View.frame.origin.y + title2View.frame.size.height content:kSection2Content];
    [self.scrollView addSubview:content2Label];
    
    //师资介绍
    UIView* title3View = [self titleViewAtY:content2Label.frame.origin.y + content2Label.frame.size.height title:@"师资简介"];
    [self.scrollView addSubview:title3View];
    
    UILabel* content3Label = [self paraphLabelAtY:title3View.frame.origin.y + title3View.frame.size.height content:kSection3Content];
    [self.scrollView addSubview:content3Label];
    //课程服务
    UIView* title4View = [self titleViewAtY:content3Label.frame.origin.y + content3Label.frame.size.height  title:@"课程服务"];
    [self.scrollView addSubview:title4View];
    UILabel* content4Label = [self paraphLabelAtY:title4View.frame.origin.y + title4View.frame.size.height content:kSection4Content];
    self.teacherLabel = content4Label;
    
    [self.scrollView addSubview:content4Label];
    
}

- (void) requestDatas
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCourseIntroduction] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [bself reloadContentWithInfo:[resultInfo objectForKey:@"info"]];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadContentWithInfo:(NSDictionary *)info
{
    NSString* title = [info objectForKey:@"title"];
    
    UILabel* titleLabel = [self boldSingleLineLabelAtY:self.teacherLabel.frame.origin.y + self.teacherLabel.frame.size.height text:title];
    [self.scrollView addSubview:titleLabel];
    
    NSString* imageUrl = [info objectForKey:@"img"];
    [self.bannerImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    
    NSInteger currentTuition = [[info objectForKey:@"rmb"] integerValue];
    NSInteger originTution = [[info objectForKey:@"marketprice"] integerValue];
    UILabel* tuitionLabel = [self tuitionLabelAtOriginY:titleLabel.frame.origin.y + titleLabel.frame.size.height currentTuition:currentTuition originTuition:originTution];
    [self.scrollView addSubview:tuitionLabel];
    
    NSArray* hours = [info objectForKey:@"course_content"];
    NSInteger idx = 0;
    for (NSDictionary* hourInfo in hours)
    {
        DFCourseChapterTitleItem* item = [[DFCourseChapterTitleItem alloc] initWithDictionary:hourInfo];
        
        UIView* hourView = [self chapertItemViewAtOriginY:(tuitionLabel.frame.origin.y + tuitionLabel.frame.size.height + idx * kChapterItemHeight) title:item];
        [self.scrollView addSubview:hourView];
        
        ++idx;
    }
    
    UILabel* hoursCountLabel = [self singleLineLabelAtY:tuitionLabel.frame.origin.y + tuitionLabel.frame.size.height + (idx+1) * kChapterItemHeight text:[NSString stringWithFormat:@"标准课时：%d个", idx]];
    [self.scrollView addSubview:hoursCountLabel];
    
    NSInteger studentCount = [[info objectForKey:@"student_count"] integerValue];
    UILabel* studentCountLable = [self singleLineLabelAtY:hoursCountLabel.frame.origin.y+hoursCountLabel.frame.size.height text:[NSString stringWithFormat:@"班级人数：%d人", studentCount]];
    [self.scrollView addSubview:studentCountLable];
    
    UILabel* contentTitleLabel = [self singleLineLabelAtY:studentCountLable.frame.origin.y+studentCountLable.frame.size.height text:@"课程说明"];
    [self.scrollView addSubview:contentTitleLabel];
    
    UIButton* callButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 292 - 2 * kMarginLeftRight) / 2, studentCountLable.frame.origin.y+studentCountLable.frame.size.height + idx * kChapterItemHeight + 20, 292, 43)];
    callButton.backgroundColor = [UIColor clearColor];
    callButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    callButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
    [callButton setTitle:@"电话咨询" forState:UIControlStateNormal];
    [callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [callButton setImage:[UIImage imageNamed:@"icon_call.png"] forState:UIControlStateNormal];
    [callButton setBackgroundImage:[UIImage imageNamed:@"bkg_long_call.png"] forState:UIControlStateNormal];
    callButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [callButton addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:callButton];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width - 2 * kMarginLeftRight, (callButton.frame.origin.y+callButton.frame.size.height + idx * kChapterItemHeight) + 20);
}

- (void) callButtonClicked:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"电话咨询" message:@"呼叫 612-05-327 ？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL* telUrl = [NSURL URLWithString:@"tel://612052822"];
        [[UIApplication sharedApplication] openURL:telUrl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *) titleViewAtY:(CGFloat)originY title:(NSString *)title
{
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width - 2 * kMarginLeftRight, 21)];
    
    UIView* flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 15)];
    flagView.backgroundColor = kMainDarPinkColor;
    [titleView addSubview:flagView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 16)];
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    label.text = title;
    label.textColor = kMainDarPinkColor;
    [titleView addSubview:label];
    
    UIView* lineImageView = [[UIView alloc] initWithFrame:CGRectMake(0, kTitleHeight - 1, self.view.frame.size.width - 2 * kMarginLeftRight, 1)];
    lineImageView.backgroundColor = RGBCOLOR(232, 199, 202);
    [titleView addSubview:lineImageView];
    
    return titleView;
}

- (UILabel *) paraphLabelAtY:(CGFloat)originY content:(NSString *)content
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width - 2 * kMarginLeftRight, 34)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = RGBCOLOR(82, 81, 81);
    label.text = content;
    label.numberOfLines = 0;
    
    CGSize size = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 2 * kMarginLeftRight, 100)];
    CGRect labelFrame = label.frame;
    labelFrame.size = size;
    label.frame = labelFrame;
    
    return label;
}

#define kBoldTextColor RGBCOLOR(99, 99, 99)

- (UILabel *) boldSingleLineLabelAtY:(CGFloat)originY text:(NSString *)text
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width, 16)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kBoldTextColor;
    label.font = [UIFont boldSystemFontOfSize:15];
    
    label.text = text;
    return label;
}

- (UILabel *) singleLineLabelAtY:(CGFloat)originY text:(NSString *)text
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width, 16)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kBoldTextColor;
    label.font = [UIFont systemFontOfSize:13];
    
    label.text = text;
    return label;
}

- (UILabel *) tuitionLabelAtOriginY:(CGFloat)originY currentTuition:(NSInteger)tuition originTuition:(NSInteger)originTuition
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width, 16)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    
//    NSAttributedString* normalAttributedText = [[NSAttributedString alloc] initWithString:@"RMB：" attributes:@{NSForegroundColorAttributeName : kBoldTextColor}];
//    NSAttributedString* currentTuitionText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d元  ", tuition] attributes:@{NSForegroundColorAttributeName : kBoldTextColor}];
//    
//    NSMutableDictionary* deletedAttributes = [NSMutableDictionary dictionary];
//    [deletedAttributes setObject:kBoldTextColor forKey:NSForegroundColorAttributeName];
//    [deletedAttributes setObject:[UIColor redColor] forKey:NSStrikethroughColorAttributeName];
//    [deletedAttributes setObject:@2 forKey:NSStrikethroughStyleAttributeName];
//    NSAttributedString* originTuitionText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"（市场价%d元）", originTuition] attributes:deletedAttributes];
    
    
    NSString* normalText = [NSString stringWithFormat:@"%d元 ", tuition];
    NSString* originText = [NSString stringWithFormat:@"（市场价%d元）", originTuition];
    
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"RMB：%@%@", normalText, originText] attributes:@{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleNone)}];
    [attributedText addAttribute:NSForegroundColorAttributeName value:kBoldTextColor range:NSMakeRange(0, 4)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:kMainDarPinkColor range:NSMakeRange(4, normalText.length)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:kBoldTextColor range:NSMakeRange(4 + normalText.length, originText.length)];
    [attributedText addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(4 + normalText.length, originText.length)];
    [attributedText addAttribute:NSStrikethroughColorAttributeName value:kMainDarPinkColor range:NSMakeRange(4 + normalText.length, originText.length)];
    
    label.attributedText = attributedText;
    
    return label;
}

- (UIView *) chapertItemViewAtOriginY:(NSInteger)originY title:(DFCourseChapterTitleItem *)chapterTitle
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(6, originY, self.view.frame.size.width, kChapterItemHeight)];
    
    UIImageView* circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 6, 6)];
    circleView.image = [UIImage imageNamed:@"flag_red_circle.png"];
    [view addSubview:circleView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width, kChapterItemHeight)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%@  %@", chapterTitle.title, chapterTitle.topic];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kBoldTextColor;
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    
    return view;
}

@end
