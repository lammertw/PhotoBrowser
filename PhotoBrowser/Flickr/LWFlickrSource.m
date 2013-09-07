//
//  LWFlickrSource.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import "LWFlickrSource.h"
#import "LWPhoto.h"

#import <FlickrKit/FlickrKit.h>

#define FLICKR_API_KEY @"06f6f158de8552e6f7d695602fc3dad4"
#define FLICKR_SECRET @"691e3ee4baceec08"

NSString * const LWFlickrSourceIdentifier = @"Flickr";

@implementation LWFlickrSource

+ (LWFlickrSource*)sharedFlickrSource {
    static LWFlickrSource *flickSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flickSource = [[self alloc] init];
    });
    return flickSource;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [[FlickrKit sharedFlickrKit] initializeWithAPIKey:FLICKR_API_KEY sharedSecret:FLICKR_SECRET];
    }
    return self;
}

-(NSString *)sourceIdentifier
{
    return LWFlickrSourceIdentifier;
}

-(NSOperation *)doRequest:(LWPhotoRequest *)request completion:(LWPhotoSourceRequestCompletion)completion
{
    id<FKFlickrAPIMethod> method;
    switch (request.type) {
        case LWPopularPhotos:
        {
            FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
            interesting.per_page  = [NSString stringWithFormat:@"%d", request.limit];
            interesting.page = [NSString stringWithFormat:@"%d", ((int)(request.start / request.limit)) + 1];
            
            method = interesting;
        }
            break;
        case LWSearchPhotos:
        {
            FKFlickrPhotosSearch *search = [[FKFlickrPhotosSearch alloc] init];
            search.text = request.query;
            search.per_page  = [NSString stringWithFormat:@"%d", request.limit];
            search.page = [NSString stringWithFormat:@"%d", ((int)(request.start / request.limit)) + 1];
            
            method = search;
        }
            break;
            
        default:
            // if a proper value is provided to the request type this will never be called
            break;
    }
    
    return [[FlickrKit sharedFlickrKit] call:method completion:^(NSDictionary *response, NSError *error) {
        NSMutableArray *photos;
        if (response)
        {
            photos = [NSMutableArray array];
            for (NSDictionary *photoDictionary in [response valueForKeyPath:@"photos.photo"]) {
                
                LWFlickrPhoto *photo = [[LWFlickrPhoto alloc] init];
                photo.source = LWFlickrSourceIdentifier;
                photo.thumbURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeThumbnail100 fromPhotoDictionary:photoDictionary];
                photo.photoURL = [[FlickrKit sharedFlickrKit] photoURLForSize:FKPhotoSizeMedium640 fromPhotoDictionary:photoDictionary];
                
                // Flickr specific
                photo.identifier = [photoDictionary objectForKey:@"id"];
                photo.owner = [photoDictionary objectForKey:@"owner"];
                photo.title = [photoDictionary objectForKey:@"title"];
                
                [photos addObject:photo];
            }
        }
        else
        {
            photos = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(photos, error);
        });
    }];
}

-(void)photoInfo:(LWFlickrPhoto *)photo completion:(void (^)(LWPhotoInfo *, NSError *))completion
{
    FKFlickrPhotosGetInfo *getPhotoInfoMethod = [[FKFlickrPhotosGetInfo alloc] init];
    getPhotoInfoMethod.photo_id = photo.identifier;
    [[FlickrKit sharedFlickrKit] call:getPhotoInfoMethod completion:^(NSDictionary *response, NSError *error) {
        LWPhotoInfo *info = nil;
        if (response)
        {
            info = [[LWPhotoInfo alloc] init];
            info.caption = photo.title;
            
            info.date = [NSDate dateWithTimeIntervalSince1970:[[response valueForKeyPath:@"photo.dates.posted"] intValue]];
            
            FKFlickrPeopleGetInfo *getPersonInfoMethod = [[FKFlickrPeopleGetInfo alloc] init];
            getPersonInfoMethod.user_id = photo.owner;
            [[FlickrKit sharedFlickrKit] call:getPersonInfoMethod completion:^(NSDictionary *response, NSError *error) {

                if (response)
                {
                    info.owner = [response valueForKeyPath:@"person.username._content"];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(info, error);
                });
            }];
            
            info.owner = [response valueForKeyPath:@"person.username._content"];
            info.caption = photo.title;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(info, error);
            });
        }
    }];
}

@end
