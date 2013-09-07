//
//  LWFlickrPhoto.h
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/7/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LWPhoto.h"

@interface LWFlickrPhoto : LWPhoto

@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *owner;
@property (copy, nonatomic) NSString *title;

@end
