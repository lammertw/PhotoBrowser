//
//  LWPhotoSource.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoRequest.h"

/**
 * The completion block for requesting photos.
 */
typedef void(^LWPhotoSourceRequestCompletion)(NSArray *photos, NSError *error);

/**
 * A source from which photos can be requested.
 */
@protocol LWPhotoSource <NSObject>

/**
 * Defines a unique identifier of this source.
 */
-(NSString *)sourceIdentifier;

/**
 * Execute a request to retrieve photos.
 *
 * @param request Defines what kind of request should be executed.
 * @param completion The completion block that is called when the request finishes. If it failed, the photos array will be empty and the error will contain the reason of failure.
 */
-(NSOperation*)doRequest:(LWPhotoRequest*)request completion:(LWPhotoSourceRequestCompletion)completion;

@end
