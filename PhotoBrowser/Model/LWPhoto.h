//
//  LWPhoto.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoInfo.h"

/**
 * A photo object with URL's to remote image locations.
 */
@interface LWPhoto : NSObject

/**
 * The source identifier from the source of the image.
 */
@property (copy, nonatomic) NSString *source;

/**
 * The url to a thumbnail version of the image.
 */
@property (copy, nonatomic) NSURL *thumbURL;

/**
 * The url to the full photo image.
 */
@property (copy, nonatomic) NSURL *photoURL;

/**
 * The photo info of this photo. Always use photoInfo: to get the info instead of accessing this property directly.
 */
@property (strong, nonatomic) LWPhotoInfo *photoInfo;

/**
 * Get the photo info of this photo. The result might be returned synchronous if cached or it mught be asynchronous when retrieved from the source.
 *
 * @param completion The completion block invoked when hte photo info is available. If the photo info is nil, the info could not be retrieved.
 */
-(void)photoInfo:(void(^)(LWPhotoInfo *photoInfo))completion;

@end
