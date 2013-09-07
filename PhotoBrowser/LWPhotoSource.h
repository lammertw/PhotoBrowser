//
//  LWPhotoSource.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoRequest.h"

typedef void(^LWPhotoSourceRequestCompletion)(NSArray *photos, NSError *error);

@protocol LWPhotoSource <NSObject>

-(NSString *)sourceIdentifier;

-(NSOperation*)doRequest:(LWPhotoRequest*)request completion:(LWPhotoSourceRequestCompletion)completion;

@end
