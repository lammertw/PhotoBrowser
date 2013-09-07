//
//  LWPhotoInfo.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/7/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Contains additional information about a photo object.
 */
@interface LWPhotoInfo : NSObject

/**
 * The photo caption. Might be nil or an instance of NSNull.
 */
@property (copy, nonatomic) NSString *caption;

/**
 * The name of the owner of the photo. Might be nil or an instance of NSNull.
 */
@property (copy, nonatomic) NSString *owner;

/**
 * The photo date.
 */
@property (strong, nonatomic) NSDate *date;

@end
