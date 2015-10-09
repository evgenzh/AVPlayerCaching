//
//  ResourceLoaderItem.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ResourceLoaderItem : NSObject
@property (nonatomic, readonly) id task;
@property (nonatomic, readonly) id request;
@property (nonatomic, readonly) id cache;

+ (instancetype)itemWithTask:(id)task request:(id)request cache:(id)cache;
- (instancetype)initWithTask:(id)task request:(id)request cache:(id)cache;
@end
