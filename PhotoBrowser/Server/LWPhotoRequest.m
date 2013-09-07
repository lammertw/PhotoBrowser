//
//  LWPhotoRequest.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWPhotoRequest.h"

@implementation LWPhotoRequest

-(id)copyWithZone:(NSZone *)zone
{
    LWPhotoRequest *requestCopy = [[LWPhotoRequest allocWithZone:zone] init];
    requestCopy.query = self.query;
    requestCopy.type = self.type;
    requestCopy.start = self.start;
    requestCopy.limit = self.limit;
    
    return requestCopy;
}

@end
