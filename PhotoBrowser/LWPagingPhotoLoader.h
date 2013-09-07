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

-(id)initWithSource:(id<LWPhotoSource>)source forRequest:(LWPhotoRequest*)request completion:(LWPhotoPagingLoaderCompletion)completion;

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

@property (readonly, nonatomic) NSOperation *currentOperation;

@property (readonly, nonatomic) BOOL hasNext;

@end
