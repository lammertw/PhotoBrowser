//
//  LWPhotoPageViewController.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/6/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWPhotoPageViewController : UIViewController

@property (strong, nonatomic) NSArray *photos;
@property (nonatomic) int currentPhotoIndex;

@end
