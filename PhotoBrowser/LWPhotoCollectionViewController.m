//
//  LWPhotoCollectionViewController.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWPhotoCollectionViewController.h"

#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <SDNetworkActivityIndicator/SDNetworkActivityIndicator.h>

#import "LWPhotoSource.h"
#import "LWFlickrSource.h"
#import "LWInstragramSource.h"
#import "LWPagingPhotoLoader.h"
#import "LWPhotoCell.h"
#import "LWPhoto.h"
#import "LWPhotoPageViewController.h"

/*
 * specifying 16 as page limit is a bit of a hack since we know that instagram always returns 16 photos and doesn't have paging for their popular photos
 * they also seem to return 16 new photos each request, so having a value of 16 will make it look like we have paging for instagram (might contain duplicates though)
 */
#define kLWLimit 16

#define kLWShowPhotoSegue @"ShowPhoto"

typedef enum {
    LWFlickr,
    LWInstagram
} LWSourceType;


@interface LWPhotoCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) LWPagingPhotoLoader *pagingPhotoLoader;
@property (strong, nonatomic) LWPhotoRequest *requestTemplate;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sourceTypeControl;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic) BOOL interacting;
@property (nonatomic) BOOL presenting;

@end

@implementation LWPhotoCollectionViewController

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
    
    self.requestTemplate = [[LWPhotoRequest alloc] init];
    self.requestTemplate.limit = kLWLimit;
    self.requestTemplate.type = LWPopularPhotos;
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.top += CGRectGetHeight(self.searchBar.bounds);
    self.collectionView.contentInset = contentInset;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.collectionView addSubview:self.refreshControl];
    
    [self createPagingLoader];
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


-(id<LWPhotoSource>)photoSource
{
    id<LWPhotoSource> source;
    switch (self.sourceTypeControl.selectedSegmentIndex) {
        case LWFlickr:
            source = [LWFlickrSource sharedFlickrSource];
            break;
        case LWInstagram:
            source = [LWInstragramSource sharedInstagramSource];
            break;
        default:
            break;
    }
    return source;
}

-(void)cancelLoading
{
    if (self.pagingPhotoLoader.currentOperation && !self.pagingPhotoLoader.currentOperation.isCancelled)
    {
        [[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
        [self.refreshControl endRefreshing];
        [self.pagingPhotoLoader.currentOperation cancel];
    }
}

-(void)createPagingLoader
{
    if (self.photos)
    {
        // clear the collection view to show something new is happening
        self.photos = nil;
        [self.collectionView reloadData];
    }

    [self cancelLoading];
    self.pagingPhotoLoader = [[LWPagingPhotoLoader alloc] initWithSource:self.photoSource forRequest:self.requestTemplate completion:^(NSArray *photos, NSError *error, BOOL initial) {
        [[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
        [self.refreshControl endRefreshing];
        if (error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.loading", @"loading photos failed") message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"error.doneButton", @"close the the error alert view"), nil];
            [alertView show];
        }
        else
        {
            if (initial)
            {
                if (photos.count == 0)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error.noPhotos.title", "no photos found for search alert view title") message:NSLocalizedString(@"error.noPhotos.title.desctiption", @"no photos found for search alert view") delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"error.doneButton", @"close the the error alert view"), nil];
                    [alertView show];
                }
                else
                {
                    self.photos = photos.mutableCopy;
                }
            }
            else
            {
                [self.photos addObjectsFromArray:photos];
            }
            if (self.photos)
            {
                [self.collectionView reloadData];
            }
        }
    }];
    [self loadNextPage];
}

-(void)loadNextPage
{
    if ([self.pagingPhotoLoader loadNext] != nil)
    {
        [[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
        [self.refreshControl beginRefreshing];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(    NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UI Actions

- (IBAction)findPopularPhotos:(id)sender {
    
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    
    self.requestTemplate.query = nil;
    self.requestTemplate.type = LWPopularPhotos;
    
    [self createPagingLoader];
}

- (IBAction)changePhotoSource:(id)sender {
    [self createPagingLoader];
}

- (IBAction)pinchToPresent:(UIPinchGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
            self.interacting = YES;
            
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell*)gestureRecognizer.view];
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self performSegueWithIdentifier:kLWShowPhotoSegue sender:self];
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            // consider scale 2 as 100%
            float percentComplete = gestureRecognizer.scale - 1.0f;
            [self.interactiveTransition updateInteractiveTransition:percentComplete];
            break;
        }
        case UIGestureRecognizerStateEnded:
            if (gestureRecognizer.velocity > 0.5 || (gestureRecognizer.scale - 1.0f) > 0.8f)
            {
                [self.interactiveTransition finishInteractiveTransition];
            }
            else
            {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            [self.interactiveTransition cancelInteractiveTransition];
            break;
        default:
            break;
    }
}

- (IBAction)pinchToDismiss:(UIPinchGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
            self.interacting = YES;
            
            LWPhotoPageViewController *photoPageViewController = (LWPhotoPageViewController*)self.presentedViewController;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:photoPageViewController.currentPhotoIndex inSection:0];
            
            
            LWPhotoCell *cell = (LWPhotoCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            if (!cell)
            {
                // cell was off screen when opening the full screen so we need to reload it first and reselect it
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            // consider scale 0 as 100%
            float percentComplete = 1.0f - gestureRecognizer.scale;
            [self.interactiveTransition updateInteractiveTransition:percentComplete];
            break;
        }
        case UIGestureRecognizerStateEnded:
            if (gestureRecognizer.velocity < -0.5 || gestureRecognizer.scale < 0.5f)
            {
                [self.interactiveTransition finishInteractiveTransition];
            }
            else
            {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            [self.interactiveTransition cancelInteractiveTransition];
            break;
        default:
            break;
    }
}

-(void)refresh
{
    [self cancelLoading];
    [self.pagingPhotoLoader reset];
    [self loadNextPage];
}

#pragma mark - Collection View Data Source

-(int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LWPhotoCell";
    LWPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    LWPhoto *photo = self.photos[indexPath.row];
    
    [cell.imageView setImageWithURL:photo.thumbURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    if (cell.gestureRecognizers.count == 0)
    {
        [cell addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToPresent:)]];
    }
    
    if (indexPath.row >= self.photos.count - 6)
    {
        // start loading the next page when coming near the bottom
        [self loadNextPage];
    }
    
    return cell;
}

#pragma mark - Collection View Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LWPhotoCell *cell = (LWPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.imageView.image)
    {
        [self performSegueWithIdentifier:kLWShowPhotoSegue sender:self];
    }
}

#pragma mark - Search Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    self.requestTemplate.query = searchBar.text;
    self.requestTemplate.type = LWSearchPhotos;
    
    [self createPagingLoader];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kLWShowPhotoSegue])
    {
        LWPhotoPageViewController *photoPageViewController = segue.destinationViewController;
        
        photoPageViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        photoPageViewController.photos = self.photos;
        
        [photoPageViewController setTransitioningDelegate:self];
        
        [photoPageViewController.view addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToDismiss:)]];
        
        NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.lastObject;
        photoPageViewController.currentPhotoIndex = selectedIndexPath.row;
    }
}

#pragma mark - View Controller Transitioning Delegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interacting ? self.interactiveTransition : nil;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interacting ? self.interactiveTransition : nil;
}

#pragma mark - View Controller Animated Transitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
    
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.lastObject;
    LWPhotoCell *selectedCell = (LWPhotoCell*)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    
    CGRect imageFrame = [self.view convertRect:selectedCell.frame fromView:selectedCell.superview];
    UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    tmpImageView.image = selectedCell.imageView.image;

    

    if (self.presenting) {
        
        
        [transitionContext.containerView addSubview:fromView];
        fromView.frame = endFrame;

        toView.alpha = 0.0f;
         
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            toView.frame = endFrame;
            toView.alpha = 1.0f;
            
            fromView.alpha = 0.0f;
            
            float endFrameRatio = endFrame.size.width / endFrame.size.height;
            float imageRatio = tmpImageView.image.size.width / tmpImageView.image.size.height;
            CGSize endImageSize = CGSizeZero;
            if (imageRatio > endFrameRatio)
            {
                // use full width
                endImageSize = CGSizeMake(endFrame.size.width, endFrame.size.width / imageRatio);
            }
            else
            {
                // use full height
                endImageSize = CGSizeMake(endFrame.size.width * imageRatio, endFrame.size.height);
            }
            tmpImageView.frame = CGRectMake((endFrame.size.width - endImageSize.width) / 2, (endFrame.size.height - endImageSize.height) / 2, endImageSize.width, endImageSize.height);
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            self.interacting = NO;
        }];
    }
    else
    {
        fromView.alpha = 0.0f;
        
        toView.frame = endFrame;
        toView.alpha = 0.0f;
        [transitionContext.containerView addSubview:toView];
        
        CGRect startFrame = fromView.frame;
        
        float startFrameRatio = startFrame.size.width / startFrame.size.height;
        float imageRatio = tmpImageView.image.size.width / tmpImageView.image.size.height;
        CGSize startImageSize = CGSizeZero;
        if (imageRatio > startFrameRatio)
        {
            // use full width
            startImageSize = CGSizeMake(startFrame.size.width, startFrame.size.width / imageRatio);
        }
        else
        {
            // use full height
            startImageSize = CGSizeMake(startFrame.size.width * imageRatio, startFrame.size.height);
        }
        tmpImageView.frame = CGRectMake((startFrame.size.width - startImageSize.width) / 2, (startFrame.size.height - startImageSize.height) / 2, startImageSize.width, startImageSize.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            tmpImageView.frame = imageFrame;
            
            toView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if ([transitionContext transitionWasCancelled])
            {
                fromView.alpha = 1.0f;
            }

            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            self.interacting = NO;
        }];
    }
    
    [transitionContext.containerView addSubview:tmpImageView];

}

@end
