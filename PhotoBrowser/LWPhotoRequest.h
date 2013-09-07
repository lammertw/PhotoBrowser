//
//  LWPhotoRequest.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    LWPopularPhotos,
    LWSearchPhotos
} LWRequestType;

@interface LWPhotoRequest : NSObject<NSCopying>

@property (nonatomic) LWRequestType type;
@property (copy, nonatomic) NSString *query;
@property (nonatomic) int start;
@property (nonatomic) int limit;

- (id)copyWithZone:(NSZone *)zone;

@end
