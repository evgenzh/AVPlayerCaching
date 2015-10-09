//
//  CachableData.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachableData : NSObject
@property (nonatomic, copy) NSData *availableData;

- (instancetype)initWithCachedFileName:(NSString *)fileName;
- (NSData *)readData:(unsigned long long)startOffset length:(unsigned long long)numberOfBytes;
- (NSError *)appendData:(NSData *)data;
@end
