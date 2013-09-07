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

/**
 * Concrete class of LWPhotoSource for Flickr.
 */
@interface LWFlickrSource : NSObject<LWPhotoSource>

/**
 * The shared singleton instance.
 */
+(LWFlickrSource*)sharedFlickrSource;

/**
 * Request photo info of the specified photo.
 *
 * @param photo The photo for which to get info.
 * @param completion The completion handler that is called when the request completes.
 */
-(void)photoInfo:(LWFlickrPhoto*)photo completion:(void(^)(LWPhotoInfo *info, NSError *error))completion;

@end
