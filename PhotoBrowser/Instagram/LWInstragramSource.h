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

@interface LWInstragramSource : NSObject<LWPhotoSource>

+(LWInstragramSource*)sharedInstagramSource;

@end
