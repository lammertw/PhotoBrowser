//
//  LWInstragramSource.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWInstragramSource.h"

#import <AFNetworking/AFNetworking.h>

#import "LWPhoto.h"

#define kLW_INSTAGRAM_CLIENT_ID @"c3a14a7d232940d98707b9a3f3dca18f"
#define kLW_INSTAGRAM_BASE @"https://api.instagram.com/v1/"

NSString * const LWInstagramSourceIdentifier = @"Instagram";

@implementation LWInstragramSource

+ (LWInstragramSource*)sharedInstagramSource {
    static LWInstragramSource *instagramSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instagramSource = [[self alloc] init];
    });
    return instagramSource;
}

-(NSString *)sourceIdentifier
{
    return LWInstagramSourceIdentifier;
}

-(NSOperation *)doRequest:(LWPhotoRequest *)request completion:(LWPhotoSourceRequestCompletion)completion
{
    NSString *method;
    switch (request.type) {
        case LWPopularPhotos:
            method = @"media/popular";
            break;
        case LWSearchPhotos:
            method = [NSString stringWithFormat:@"tags/%@/media/recent", request.query];
            break;
            
        default:
            // if a proper value is provided to the request type this will never be called
            break;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?client_id=%@", kLW_INSTAGRAM_BASE, method, kLW_INSTAGRAM_CLIENT_ID]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    __block AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *photos = [NSMutableArray array];
            for (NSDictionary *photoDictionary in [JSON valueForKeyPath:@"data"]) {
                
                LWPhoto *photo = [[LWPhoto alloc] init];
                photo.source = LWInstagramSourceIdentifier;
                photo.thumbURL = [NSURL URLWithString:[photoDictionary valueForKeyPath:@"images.thumbnail.url"]];
                photo.photoURL = [NSURL URLWithString:[photoDictionary valueForKeyPath:@"images.standard_resolution.url"]];

                LWPhotoInfo *info = [[LWPhotoInfo alloc] init];
                info.owner =[photoDictionary valueForKeyPath:@"caption.from.username"];
                info.caption = [photoDictionary valueForKeyPath:@"caption.text"];
                info.date = [NSDate dateWithTimeIntervalSince1970:[[photoDictionary valueForKeyPath:@"created_time"] intValue]];
                
                photo.photoInfo = info;
                
                [photos addObject:photo];
            }
        
        completion(photos, nil);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (!operation.isCancelled)
        {
            completion(nil, error);
        }
    }];
    
    [operation start];
    
    return operation;
}

@end
