//
//  LWPagingPhotoLoader.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWPagingPhotoLoader.h"

@interface LWPagingPhotoLoader()

@property (strong, nonatomic) id<LWPhotoSource> source;
@property (copy, nonatomic) LWPhotoRequest *request;

@property (nonatomic) BOOL hasNext;

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation LWPagingPhotoLoader

-(id)initWithSource:(id<LWPhotoSource>)source forRequest:(LWPhotoRequest *)request completion:(LWPhotoPagingLoaderCompletion)completion
{
    self = [super init];
    if (self)
    {
        self.source = source;        self.completion = completion;
        self.request = request;
        
        [self reset];
    }
    return self;
}

-(NSOperation *)loadNext
{
    if ((!self.currentOperation || self.currentOperation.isCancelled) && self.hasNext)
    {
        self.currentOperation = [self.source doRequest:self.request completion:^(NSArray *photos, NSError *error) {
            self.currentOperation = nil;
            
            BOOL initial = self.request.start == 0;
            if (!error)
            {
                self.request.start += self.request.limit;
                self.hasNext = photos.count == self.request.limit;
            }
            self.completion(photos, error, initial);
        }];
        
        return self.currentOperation;
    }
    
    return nil;
}

-(void)reset
{
    self.request.start = 0;
    self.hasNext = YES;
}

@end
