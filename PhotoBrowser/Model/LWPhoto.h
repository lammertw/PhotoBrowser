//
//  LWPhoto.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhotoInfo.h"

@interface LWPhoto : NSObject

@property (copy, nonatomic) NSString *source;

@property (copy, nonatomic) NSURL *thumbURL;
@property (copy, nonatomic) NSURL *photoURL;

@property (strong, nonatomic) LWPhotoInfo *photoInfo;

-(void)photoInfo:(void(^)(LWPhotoInfo *photoInfo))completion;

@end
