//
//  ThreadSafeDictionary.m
//  AvPlayerTestTask
//
//  Created by Eugene Zhuk Work on 07.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "ThreadSafeDictionary.h"

@interface ThreadSafeDictionary ()
{
    NSMutableDictionary *_data;
    dispatch_queue_t _isolationQueue;
}
@end

@implementation ThreadSafeDictionary
- (instancetype)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableDictionary alloc] init];
        _isolationQueue = dispatch_queue_create("com.TNSafeMutableDictionary.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (id)objectForKey:(id)aKey {
    __block id obj;
    dispatch_sync(_isolationQueue, ^{
        obj = [_data objectForKey:aKey];
    });
    return obj;
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_barrier_async(_isolationQueue, ^{
        [_data removeObjectForKey:aKey];
    });
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    dispatch_barrier_async(_isolationQueue, ^{
        [_data setObject:anObject forKey:aKey];
    });
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [self setObject:obj forKey:key];
}

- (NSArray *)allKeys {
    __block NSArray *keys;
    dispatch_sync(_isolationQueue, ^{
        keys = [_data allKeys];
    });
    return keys;
}

- (NSArray *)allValues {
    __block NSArray *values;
    dispatch_sync(_isolationQueue, ^{
        values = [_data allValues];
    });
    return values;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    dispatch_sync(_isolationQueue, ^{
        [_data enumerateKeysAndObjectsUsingBlock:block];
    });
}

@end
