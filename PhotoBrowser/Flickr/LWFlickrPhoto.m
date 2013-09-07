//
//  LWFlickrPhoto.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/7/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWFlickrPhoto.h"
#import "LWFlickrSource.h"

@implementation LWFlickrPhoto

-(void)photoInfo:(void (^)(LWPhotoInfo *))completion
{
    if (self.photoInfo == nil)
    {
        [[LWFlickrSource sharedFlickrSource] photoInfo:self completion:^(LWPhotoInfo *info, NSError *error) {
            self.photoInfo = info;
            completion(self.photoInfo);
        }];
    }
    else
    {
        completion(self.photoInfo);
    }
}

@end
