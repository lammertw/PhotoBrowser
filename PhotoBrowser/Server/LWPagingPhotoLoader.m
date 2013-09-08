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
@property (copy, nonatomic) LWPhotoRequest *requestTemplate;

@property (nonatomic) BOOL hasNext;

@property (strong, nonatomic) NSOperation *currentOperation;

@end

@implementation LWPagingPhotoLoader

-(id)initWithSource:(id<LWPhotoSource>)source forRequest:(LWPhotoRequest *)requestTemplate completion:(LWPhotoPagingLoaderCompletion)completion
{
    self = [super init];
    if (self)
    {
        self.source = source;
        self.completion = completion;
        self.requestTemplate = requestTemplate;
        
        [self reset];
    }
    return self;
}

-(NSOperation *)loadNext
{
    if ((!self.currentOperation || self.currentOperation.isCancelled) && self.hasNext)
    {
        self.currentOperation = [self.source doRequest:self.requestTemplate completion:^(NSArray *photos, NSError *error) {
            self.currentOperation = nil;
            
            BOOL initial = self.requestTemplate.start == 0;
            if (!error)
            {
                self.requestTemplate.start += self.requestTemplate.limit;
                self.hasNext = photos.count == self.requestTemplate.limit;
            }
            self.completion(photos, error, initial);
        }];
        
        return self.currentOperation;
    }
    
    return nil;
}

-(void)reset
{
    if (self.currentOperation && !self.currentOperation.isCancelled)
    {
        [self.currentOperation cancel];
        self.currentOperation = nil;
    }
    self.requestTemplate.start = 0;
    self.hasNext = YES;
}

@end
