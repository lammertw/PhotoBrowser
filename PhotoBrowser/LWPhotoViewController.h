//
//  LWPhotoViewController.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/6/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWPhoto.h"

@interface LWPhotoViewController : UIViewController

@property (strong, nonatomic) LWPhoto *photo;
@property (nonatomic) int pageIndex;

@end
