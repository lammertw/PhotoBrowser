//
//  LWPhotoPageViewController.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/6/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWPhotoPageViewController.h"
#import "LWPhotoViewController.h"

@interface LWPhotoPageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation LWPhotoPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setCurrentPhotoIndex:(int)currentPhotoIndex
{
    [self.pageViewController setViewControllers:@[[self photoViewControllerForIndex:currentPhotoIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(int)currentPhotoIndex
{
    LWPhotoViewController *photoViewController = self.pageViewController.viewControllers.lastObject;
    return photoViewController.pageIndex;
}

-(UIPageViewController*)pageViewController
{
    if (!_pageViewController)
    {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:0];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
    return _pageViewController;
}

-(LWPhotoViewController*)photoViewControllerForIndex:(int)index
{
    LWPhotoViewController *photoViewController = nil;
    if (index >= 0 && index < self.photos.count)
    {
        photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LWPhotoViewController"];
        photoViewController.pageIndex = index;
        photoViewController.photo = self.photos[index];
    }
    
    return photoViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [self photoViewControllerForIndex:((LWPhotoViewController*)viewController).pageIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [self photoViewControllerForIndex:((LWPhotoViewController*)viewController).pageIndex + 1];
}

@end
