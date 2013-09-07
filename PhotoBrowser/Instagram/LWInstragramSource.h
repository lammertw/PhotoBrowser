//
//  LWInstragramSource.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoSource.h"


extern NSString * const LWInstagramSourceIdentifier;

/**
 * Concrete class of LWPhotoSource for Flickr.
 *
 * This implementation is very basic and does not support paging or a limit.
 */
@interface LWInstragramSource : NSObject<LWPhotoSource>

/**
 * The shared singleton instance.
 */
+(LWInstragramSource*)sharedInstagramSource;

@end
