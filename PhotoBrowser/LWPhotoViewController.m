//
//  LWPhotoViewController.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/6/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWPhotoViewController.h"
#import <UIActivityIndicator-for-SDWebImage/UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface LWPhotoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *ownerLabel;
@property (strong, nonatomic) IBOutlet UILabel *captionLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *sourceLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic) BOOL fullPhotoLoaded;

@end

@implementation LWPhotoViewController

+ (NSDateFormatter*)formatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
    });
    return formatter;
}

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
    
    __weak LWPhotoViewController *weakSelf = self;
    
    // first set thumbnail since it's probably in cache or else else should be downloaded fast
    [self.imageView setImageWithURL:self.photo.thumbURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image)
        {
            [weakSelf.imageView setImageWithURL:weakSelf.photo.photoURL placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if (image)
                {
                    weakSelf.fullPhotoLoaded = YES;
                    [weakSelf updateShareButton];
                }
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
    } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    //self.infoView.alpha = 0.5f;
    
    [self loadInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadInfo
{
    self.ownerLabel.hidden = YES;
    self.captionLabel.hidden = YES;
    self.dateLabel.hidden = YES;
    self.sourceLabel.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self.photo photoInfo:^(LWPhotoInfo *photoInfo) {
        [self.activityIndicatorView stopAnimating];
        if (photoInfo)
        {
            if (photoInfo.owner && ((id)photoInfo.owner) != [NSNull null])
            {
                self.ownerLabel.hidden = NO;
                NSString *ownerFormat = NSLocalizedString(@"photoInfo.ownerLabelFormat");
                self.ownerLabel.text = [NSString stringWithFormat:ownerFormat, photoInfo.owner];
            }
            if (photoInfo.caption && ((id)photoInfo.caption) != [NSNull null])
            {
                self.captionLabel.hidden = NO;
                self.captionLabel.text = photoInfo.caption;
            }
            if (photoInfo.date && ((id)photoInfo.date) != [NSNull null])
            {
                self.dateLabel.hidden = NO;
                self.dateLabel.text = [[[self class] formatter] stringFromDate:photoInfo.date];
            }
            NSString *sourceKey = [NSString stringWithFormat:@"photoInfo.source%@", self.photo.source];
            self.sourceLabel.hidden = NO;
            self.sourceLabel.text = NSLocalizedString(sourceKey);
            
            [self updateShareButton];
        }
    }];
}

-(void)updateShareButton
{
    if (![self.activityIndicatorView isAnimating] && self.fullPhotoLoaded)
    {
        self.shareButton.hidden = NO;
    }
}

- (IBAction)share:(id)sender {
    NSMutableArray *items = @[self.imageView.image].mutableCopy;
    if (self.captionLabel.text)
    {
        [items addObject:self.captionLabel.text];
    }
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[]];
        
        [self presentViewController:activityController animated:YES completion:^{
    }];
}

@end
