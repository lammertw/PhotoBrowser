//
//  LWPhotoRequest.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The different request types that are available.
 */
typedef enum {
    LWPopularPhotos,
    LWSearchPhotos
} LWRequestType;

@interface LWPhotoRequest : NSObject<NSCopying>

/**
 * The request type.
 */
@property (nonatomic) LWRequestType type;

/**
 * An optional query value, currently only used for the LWSearchPhotos type.
 */
@property (copy, nonatomic) NSString *query;

/**
 * The start index. Can be used for paging when combining with the limit property. If limit is omitted, the start property value is not used.
 */
@property (nonatomic) int start;

/**
 * A limit which specifies the maximum number of photos to retrieve. Defaults to source specific limit.
 */
@property (nonatomic) int limit;

@end
