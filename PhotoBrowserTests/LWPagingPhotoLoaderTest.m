//
//  LWPagingPhotoLoaderTest.m
//  PhotoBrowser
//
//  Created by Lammert Westerhoff on 9/5/13.
//  Copyright (c) 2013 Westerhoff. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LWPagingPhotoLoader.h"

@interface LWPhotoSourceMock : NSObject<LWPhotoSource>

-(id)initWithSize:(int)size;

@property (nonatomic) int size;
@property (nonatomic) int cursor;

@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation LWPhotoSourceMock

-(id)initWithSize:(int)size
{
    self = [super init];
    if (self)
    {
        self.size = size;
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(NSString *)sourceIdentifier
{
    return @"mock";
}

-(NSOperation *)doRequest:(LWPhotoRequest *)request completion:(LWPhotoSourceRequestCompletion)completion
{
    
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.size];
        for (int i = request.start; i < request.start + request.limit && i < self.size; i++)
        {
            [result addObject:@(i)];
        }
        completion(result, nil);
    }];
    
    [self.queue addOperation:operation];
    
    return operation;
}

@end


@interface LWPagingPhotoLoaderTest : XCTestCase



@end

@implementation LWPagingPhotoLoaderTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testInitial
{
    LWPhotoSourceMock *source = [[LWPhotoSourceMock alloc] initWithSize:100];
    LWPhotoRequest *request = [[LWPhotoRequest alloc] init];
    request.limit = 25;
    
    __block BOOL shouldBeInitial = YES;
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    LWPagingPhotoLoader *loader = [[LWPagingPhotoLoader alloc] initWithSource:source forRequest:request completion:^(NSArray *photos, NSError *error, BOOL initial) {
        
        XCTAssertTrue(initial == shouldBeInitial, "Incorrect value for 'initial'");
        XCTAssertTrue(photos.count == 25, "Incorrect result count");
        shouldBeInitial = NO;
        dispatch_semaphore_signal(semaphore);
    }];
    [loader loadNext];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    XCTAssertFalse(shouldBeInitial);
}


- (void)testCount
{
    LWPhotoSourceMock *source = [[LWPhotoSourceMock alloc] initWithSize:10];
    LWPhotoRequest *request = [[LWPhotoRequest alloc] init];
    request.limit = 25;
    
    __block BOOL shouldBeInitial = YES;
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    LWPagingPhotoLoader *loader = [[LWPagingPhotoLoader alloc] initWithSource:source forRequest:request completion:^(NSArray *photos, NSError *error, BOOL initial) {
        
        XCTAssertTrue(initial == shouldBeInitial, "Incorrect value for 'initial'");
        XCTAssertTrue(photos.count == 10, "Incorrect result count");
        shouldBeInitial = NO;
        dispatch_semaphore_signal(semaphore);
    }];
    [loader loadNext];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    XCTAssertFalse(shouldBeInitial);
}

- (void)testTwoPage
{
    LWPhotoSourceMock *source = [[LWPhotoSourceMock alloc] initWithSize:35];
    LWPhotoRequest *request = [[LWPhotoRequest alloc] init];
    request.limit = 25;
    
    __block BOOL shouldBeInitial = YES;
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block LWPagingPhotoLoader *loader = [[LWPagingPhotoLoader alloc] initWithSource:source forRequest:request completion:^(NSArray *photos, NSError *error, BOOL initial) {
        
        if (shouldBeInitial)
        {
            XCTAssertTrue(initial == shouldBeInitial, "Incorrect value for 'initial'");
            XCTAssertTrue(photos.count == 25, "Incorrect result count");
            XCTAssertTrue(loader.hasNext, @"Loader should have next");
        
            shouldBeInitial = NO;
            
            [loader loadNext];
        }
        else
        {
            XCTAssertTrue(initial == shouldBeInitial, "Incorrect value for 'initial'");
            XCTAssertTrue(photos.count == 10, "Incorrect result count");
            XCTAssertFalse(loader.hasNext, @"Loader should not have next");
            dispatch_semaphore_signal(semaphore);
        }
    }];
    [loader loadNext];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    XCTAssertFalse(shouldBeInitial);
}

@end
