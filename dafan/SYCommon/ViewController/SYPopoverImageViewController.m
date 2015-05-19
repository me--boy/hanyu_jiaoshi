//
//  SYPopoverImageViewController.m
//  dafan
//
//  Created by iMac on 14/10/24.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYPopoverImageViewController.h"
#import "UIImageView+WebCache.h"
#import "DFAppDelegate.h"

@interface SYPopoverImageViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIImageView* imageView;

@property(nonatomic) CGFloat lastScale;
@property(nonatomic) CGRect originImageViewFrame;

@property(nonatomic, strong) NSString* imageUrl;


@property(nonatomic, strong) UIPanGestureRecognizer* panOnImageView;
@property(nonatomic) CGRect beginImageFrame;;

@end

@implementation SYPopoverImageViewController

- (id) initWithImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.image = image;
    }
    return self;
}

- (id) initWithImageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self)
    {
        self.imageUrl = imageUrl;
    }
    return self;
}

- (void) popoverFromView:(UIView *)view
{
    UIWindow* window = ((DFAppDelegate *)([UIApplication sharedApplication].delegate)).window;
    self.originImageViewFrame = [view convertRect:view.bounds toView:window];
    [window addSubview:self.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lastScale = 1.0;
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.originImageViewFrame];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.userInteractionEnabled = YES;
    if (self.imageUrl != nil)
    {
        [self.imageView setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:self.image];
    }
    else
    {
        self.imageView.image = self.image;
    }
    
    [self.view addSubview:self.imageView];
    
    UIPinchGestureRecognizer* pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePhoto:)];
    pin.delegate = self;
    [self.imageView addGestureRecognizer:pin];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewRecognize:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.panOnImageView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImageViewRecognize:)];
    self.panOnImageView.enabled = NO;
    self.panOnImageView.maximumNumberOfTouches = 1;
    self.panOnImageView.delegate = self;
    [self.imageView addGestureRecognizer:self.panOnImageView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize size = self.view.frame.size;
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.2 animations:^{
        bself.imageView.frame = CGRectMake(0, (size.height - size.width) / 2, size.width, size.width);
        bself.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    }];
    
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#define kMaxOffset 70

- (void) panImageViewRecognize:(UIPanGestureRecognizer *)gesture
{
    CGRect imageFrame = self.imageView.frame;
    CGSize size = self.view.frame.size;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.beginImageFrame = imageFrame;
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translate = [gesture translationInView:self.view];
            imageFrame.origin.x = self.beginImageFrame.origin.x + translate.x;
            if (imageFrame.size.height > size.height)
            {
                imageFrame.origin.y = self.beginImageFrame.origin.y + translate.y;
            }
            
            if (imageFrame.origin.x > kMaxOffset)
            {
                imageFrame.origin.x = kMaxOffset;
            }
            if (imageFrame.size.height > size.height && imageFrame.origin.y > kMaxOffset)
            {
                imageFrame.origin.y = kMaxOffset;
            }
            if (imageFrame.origin.x < size.width - imageFrame.size.width - kMaxOffset)
            {
                imageFrame.origin.x = size.width - imageFrame.size.width - kMaxOffset;
            }
            if (imageFrame.size.height > size.height && imageFrame.origin.y < size.height - imageFrame.size.height - kMaxOffset)
            {
                imageFrame.origin.y = size.height - imageFrame.size.height - kMaxOffset;
            }
            self.imageView.frame = imageFrame;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint translate = [gesture translationInView:self.view];
            imageFrame.origin.x = self.beginImageFrame.origin.x + translate.x;
            if (imageFrame.size.height > size.height)
            {
                imageFrame.origin.y = self.beginImageFrame.origin.y + translate.y;
            }
            
            CGFloat offsetX = 0;
            CGFloat offsetY = 0;
            if (imageFrame.origin.x > 0)
            {
                offsetX = imageFrame.origin.x;
                imageFrame.origin.x = 0;
            }
            if (imageFrame.size.height > size.height && imageFrame.origin.y > 0)
            {
                offsetY = imageFrame.origin.y;
                imageFrame.origin.y = 0;
            }
            if (imageFrame.origin.x < size.width - imageFrame.size.width)
            {
                offsetX = size.width - (imageFrame.origin.x + imageFrame.size.width);
                imageFrame.origin.x = size.width - imageFrame.size.width;
            }
            if (imageFrame.size.height > size.height && imageFrame.origin.y < size.height - imageFrame.size.height)
            {
                offsetY = size.height - (imageFrame.origin.y + imageFrame.size.height);
                imageFrame.origin.y = size.height - imageFrame.size.height;
            }
            
            if (offsetY > 0 || offsetX > 0)
            {
                typeof(self) __weak bself = self;
                [UIView animateWithDuration:((offsetX > offsetY ? offsetX : offsetY) / kMaxOffset * 0.2) animations:^{
                    bself.imageView.frame = imageFrame;
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void) tapImageViewRecognize:(UITapGestureRecognizer *)gesture
{
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.2 animations:^{
        bself.imageView.frame = bself.originImageViewFrame;
        bself.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    } completion:^(BOOL finished){
        
        [bself.view removeFromSuperview];
        [bself removeFromParentViewController];
    }];
}


- (void) scalePhoto:(UIPinchGestureRecognizer *)gesture
{
    CGRect imageFrame = self.imageView.frame;
    CGSize size = self.view.frame.size;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        self.panOnImageView.enabled = NO;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (imageFrame.size.width < size.width)
        {
            typeof(self) __weak bself = self;
            [UIView animateWithDuration:0.2 animations:^{
                bself.imageView.frame = CGRectMake(0, (size.height - size.width) / 2, size.width, size.width);
            }];
            self.panOnImageView.enabled = NO;
        }
        else
        {
            if (imageFrame.origin.x > 0 || imageFrame.origin.x < -imageFrame.size.width)
            {
                typeof(self) __weak bself = self;
                imageFrame.origin.x = 0;
                [UIView animateWithDuration:0.2 animations:^{
                    bself.imageView.frame = imageFrame;
                }];
            }
            self.panOnImageView.enabled = YES;
        }
        
        self.lastScale = 1.0;
        
        return;
    }
    
    CGFloat scale = 1.0 - (self.lastScale - gesture.scale);
    CGAffineTransform currentTransform = gesture.view.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    gesture.view.transform = newTransform;
    
    self.lastScale = gesture.scale;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
