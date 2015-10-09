//
//  ResourceLoaderItem.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "ResourceLoaderItem.h"

@implementation ResourceLoaderItem

+ (instancetype)itemWithTask:(id)task request:(id)request {
    return [[self alloc] initWithTask:task request:request];
}

- (instancetype)initWithTask:(id)task request:(id)request {
    self = [super init];
    if (self) {
        _task = task;
        _request = request;
    }
    return self;
}

@end
