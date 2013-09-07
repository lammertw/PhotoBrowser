//
//  LWPhotoInfo.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/7/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWPhotoInfo : NSObject

@property (copy, nonatomic) NSString *caption;
@property (copy, nonatomic) NSString *owner;
@property (strong, nonatomic) NSDate *date;

@end
