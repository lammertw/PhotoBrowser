//
//  LWFlickrSource.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoSource.h"
#import "LWFlickrPhoto.h"

extern NSString * const LWFlickrSourceIdentifier;

@interface LWFlickrSource : NSObject<LWPhotoSource>

+(LWFlickrSource*)sharedFlickrSource;

-(void)photoInfo:(LWFlickrPhoto*)photo completion:(void(^)(LWPhotoInfo *info, NSError *error))completion;

@end
