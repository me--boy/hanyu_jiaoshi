//
//  MYCityPickedViewController.m
//  MY
//
//  Created by iMac on 14-7-15.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYConstDefine.h"
#import "DFColorDefine.h"
#import "SYCityPickedViewController.h"


#pragma mark - region item

@interface SYRegionItem : NSObject

@property(nonatomic) NSInteger regionId;
@property(nonatomic, strong) NSString* regionName;

@property(nonatomic, strong) NSMutableArray* subRegions;

@end

@implementation SYRegionItem

@end

#pragma mark - region picked cell

@interface SYCityPickedCell : UITableViewCell

@end

@implementation SYCityPickedCell

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = 25;
    self.textLabel.frame = frame;
}

@end

#pragma mark - header cell

@interface MYCityPickedHeaderView : UIView

@property(nonatomic, strong) UIButton* button;
@property(nonatomic) BOOL selected;

@end

@implementation MYCityPickedHeaderView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubViews];
    }
    return self;
}

- (void) setSelected:(BOOL)selected
{
    if (_selected ^ selected)
    {
        _selected = selected;
        
        self.button.selected = selected;
    }
}

- (void) initSubViews
{
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 36)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"city_bg.png"] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.button setTitleColor:kMainDarkColor forState:UIControlStateSelected];
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self addSubview:self.button];
}


@end

#pragma mark - controller

@interface SYCityPickedViewController ()

@property(nonatomic, strong) NSMutableDictionary* sectionViews;

@property(nonatomic, strong) NSMutableArray* regions;

@property(nonatomic) NSInteger defaultSection;
@property(nonatomic) NSInteger defaultRow;

@end

@implementation SYCityPickedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define kRowHeight 36.0f
#define kSectionHeight 40.0f

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"地区";
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y += 4;
    tableFrame.size.height -= 4;
    self.tableView.frame = tableFrame;
    
    self.tableView.rowHeight = kRowHeight;
    self.tableView.sectionHeaderHeight = kSectionHeight;
    self.sectionViews = [NSMutableDictionary dictionary];
    
    [self showProgress];
    [self initRegionItems];
}

- (void) initRegionItems
{
    NSString* regionsFilePath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"txt"];
    NSData* regionsData = [[NSData alloc] initWithContentsOfFile:regionsFilePath];
    
    NSError* error = nil;
    NSArray* regionInfos = nil;
    if (regionsData != nil)
    {
        regionInfos = [NSJSONSerialization JSONObjectWithData:regionsData options:kNilOptions error:&error];
    }
    
    self.regions = [NSMutableArray arrayWithCapacity:regionInfos.count];
    if (regionInfos != nil)
    {
        NSInteger selectedSection = -1;
        NSInteger selectedRow = -1;
        
        NSInteger provinceCount = regionInfos.count;
        for (NSInteger provinceIdx = 0; provinceIdx < provinceCount; ++provinceIdx)
        {
            NSDictionary* province = [regionInfos objectAtIndex:provinceIdx];
            SYRegionItem* provinceItem = [[SYRegionItem alloc] init];
            provinceItem.regionId = [[province objectForKey:@"prov_id"] integerValue];
            provinceItem.regionName = [province objectForKey:@"prov_name"];
            [self.regions addObject:provinceItem];
            if (provinceItem.regionId == self.pickedProvinceId)
            {
                selectedSection = provinceIdx;
            }
            
            provinceItem.subRegions = [NSMutableArray array];
            NSArray* cityInfos = [province objectForKey:@"citys"];
            NSInteger cityCount = cityInfos.count;
            for (NSInteger cityIdx = 0; cityIdx < cityCount; ++cityIdx)
            {
                NSDictionary* cityInfo = [cityInfos objectAtIndex:cityIdx];
                SYRegionItem* cityItem = [[SYRegionItem alloc] init];
                cityItem.regionId = [[cityInfo objectForKey:@"city_id"] integerValue];
                cityItem.regionName = [cityInfo objectForKey:@"city_name"];
                [provinceItem.subRegions addObject:cityItem];
                
                if (cityItem.regionId == self.pickedCityId)
                {
                    selectedRow = cityIdx;
                }
            }
        }
        
        self.defaultSection = selectedSection;
        self.defaultRow = selectedRow;
        
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.defaultSection >= 0 && self.defaultRow >= 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.defaultRow inSection:self.defaultSection] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    else if (self.defaultSection >= 0)
    {
        CGFloat offsetY = kSectionHeight * self.defaultSection;
        
        if (offsetY < self.tableView.frame.size.height)
        {
            self.tableView.contentOffset = CGPointZero;
        }
        else if (offsetY <= self.tableView.contentSize.height - self.tableView.frame.size.height)
        {
            self.tableView.contentOffset = CGPointMake(0, offsetY);
        }
        else
        {
            self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        }
    }
    
    [self hideProgress];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.regions.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SYRegionItem* item = [self.regions objectAtIndex:section];
    if (item.regionId != self.pickedProvinceId)
    {
        return 0;
    }
    else
    {
        return [[[self.regions objectAtIndex:section] subRegions] count];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MYCityPickedHeaderView* sectionView = [self.sectionViews objectForKey:[NSString stringWithFormat:@"%d",section]];
    if (sectionView == nil)
    {
        SYRegionItem* item = [self.regions objectAtIndex:section];
        sectionView = [[MYCityPickedHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        
        if (item.subRegions.count > 0)
        {
            [sectionView.button setImage:[UIImage imageNamed:@"arrow_city_collapse.png"] forState:UIControlStateNormal];
            [sectionView.button setImage:[UIImage imageNamed:@"arrow_city_extend.png"] forState:UIControlStateSelected];
            
            sectionView.button.imageEdgeInsets = UIEdgeInsetsMake(0, self.view.frame.size.width - 20, 0, 0);
            sectionView.button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        }
        else
        {
            sectionView.button.titleEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 0);
        }
        
        sectionView.selected = (self.pickedProvinceId == item.regionId);
        
        [sectionView.button setTitle:item.regionName forState:UIControlStateNormal];
        
        sectionView.button.tag = section;
        [sectionView.button addTarget:self action:@selector(sectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.sectionViews setObject:sectionView forKey:[NSString stringWithFormat:@"%d", section]];
    }
    
    return sectionView;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYCityPickedCell* cell = (SYCityPickedCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[SYCityPickedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.highlightedTextColor = kMainDarkColor;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    SYRegionItem* item = [[[self.regions objectAtIndex:indexPath.section] subRegions] objectAtIndex:indexPath.row];
    cell.textLabel.text = item.regionName;
    cell.textLabel.highlighted = item.regionId == self.pickedCityId;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SYRegionItem* provinceItem = [self.regions objectAtIndex:indexPath.section];
    SYRegionItem* cityItem = [provinceItem.subRegions objectAtIndex:indexPath.row];
    
    self.pickedProvinceId = provinceItem.regionId;
    self.pickedCityId = cityItem.regionId;
    
    self.citySelectedBlock(provinceItem.regionId, cityItem.regionId, cityItem.regionName);
    [self leftButtonClicked:nil];
}

- (void) setSectionViewSelected:(NSInteger)selectedIdx
{
    [self.sectionViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key integerValue] != selectedIdx)
        {
            ((MYCityPickedHeaderView *)obj).selected = NO;
        }
    }];
}

- (void) sectionButtonClicked:(UIButton *)sender
{
    MYCityPickedHeaderView* headerView = (MYCityPickedHeaderView *)sender.superview;
    headerView.selected = !headerView.selected;
    
    [self setSectionViewSelected:sender.tag];
    
    SYRegionItem* item = [self.regions objectAtIndex:sender.tag];
    if (item.subRegions.count > 0)
    {
        self.pickedCityId = 0;
        if (headerView.selected)
        {
            self.pickedProvinceId = item.regionId;
        }
        else
        {
            self.pickedProvinceId = 0;
        }
        
        [self.tableView reloadData];
    }
    else
    {
        self.citySelectedBlock(item.regionId, 0, item.regionName);
        [self leftButtonClicked:nil];
    }
}

@end
