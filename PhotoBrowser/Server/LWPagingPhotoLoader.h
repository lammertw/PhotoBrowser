//
//  LWPagingPhotoLoader.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoSource.h"

typedef void(^LWPhotoPagingLoaderCompletion)(NSArray *photos, NSError *error, BOOL initial);

/**
 * A wrapper around the LWPhoto Request and LWPhotoSource to make multiple requests with paging.
 */
@interface LWPagingPhotoLoader : NSObject

/**
 * Dedicated initializer.
 *
 * @param source The source to which requests will be made.
 * @param requestTemplate A request template that is the base for each request that is made.
 * @param completion The completion handler that gets called each time a request returns.
 */
-(id)initWithSource:(id<LWPhotoSource>)source forRequest:(LWPhotoRequest*)requestTemplate completion:(LWPhotoPagingLoaderCompletion)completion;

/**
 * Loads the next page of results. Returns nil if another operations is already loading the next page.
 */
-(NSOperation*)loadNext;

/**
 * Reset to the first page.
 */
-(void) reset;

@property (readonly, nonatomic) id<LWPhotoSource> source;
@property (readonly, nonatomic) int pageSize;
@property (strong, nonatomic) LWPhotoPagingLoaderCompletion completion;

/**
 * The currently executing operation, if any.
 */
@property (readonly, nonatomic) NSOperation *currentOperation;

/**
 * Check if there are additional pages that can be load.
 */
@property (readonly, nonatomic) BOOL hasNext;

@end
