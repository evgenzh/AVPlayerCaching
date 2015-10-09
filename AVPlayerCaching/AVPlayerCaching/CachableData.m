//
//  CachableData.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "CachableData.h"
#import <CommonCrypto/CommonDigest.h>

@interface CachableData (PathExtension)
+ (NSString *)fullPathForKey:(NSString *)key;
@end

@implementation CachableData (PathExtension)
#pragma mark - private
+ (NSString *)diskCachePath {
    static NSString *diskCachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *folder = @"com.CacheManager";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        diskCachePath = [paths[0] stringByAppendingPathComponent:folder];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:diskCachePath]) {
            BOOL success = [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            if (!success) {
#ifdef DEBUG
                NSLog(@"CachableData WARNING: Cache directory creation error!");
#endif
            }
        }
    });
    return diskCachePath;
}

+ (NSString *)MD5RepresentationForString:(NSString *)string {
    const char *str = [string UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *ret = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return ret;
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
    NSString *filename = [[self MD5RepresentationForString:key] stringByAppendingPathExtension:key.pathExtension];
    return filename;
}

+ (NSString *)fullPathForKey:(NSString *)key {
    return [[self diskCachePath] stringByAppendingPathComponent:[self cachedFileNameForKey:key]];
}

@end

@interface CachableData ()
@property (nonatomic,strong)NSFileHandle *writingFileHandle;
@property (nonatomic,strong)NSFileHandle *readingFileHandle;
@end

@implementation CachableData
- (instancetype)initWithCachedFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        NSString *fullPath = [[self class] fullPathForKey:fileName];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]){
            [[NSFileManager defaultManager] createFileAtPath:fullPath
                                                    contents:nil
                                                  attributes:nil];
        }
        if (!error) {
            self.writingFileHandle = [NSFileHandle fileHandleForWritingAtPath:fullPath];
            self.readingFileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
        } else {
            NSLog(@"%@", error);
        }
    }
    return self;
}

- (NSData *)availableData {
    return self.readingFileHandle.availableData;
}

- (void)dealloc {
    [self closeHandles];
}

- (void)closeHandles{
    if (self.writingFileHandle != nil){
        [self.writingFileHandle closeFile];
        self.writingFileHandle = nil;
    }
    if (self.readingFileHandle != nil){
        [self.readingFileHandle closeFile];
        self.readingFileHandle = nil;
    }
}

- (NSData *)readData:(unsigned long long)startOffset length:(unsigned long long)numberOfBytes {
    @try {
        [self.readingFileHandle seekToFileOffset:startOffset];
        NSData *data = [self.readingFileHandle readDataOfLength:numberOfBytes];
        return data;
    }
    @catch (NSException *exception) {
        NSLog(@"read cached data error %@", exception);
    }
    return nil;
}

- (NSError *)appendData:(NSData *)data {
    NSError *error;
    @try {
        [self.writingFileHandle writeData:data];
        [self.writingFileHandle synchronizeFile];
    }
    @catch (NSException *exception) {
        NSLog(@"write to file error %@", exception);
         error = [[NSError alloc] initWithDomain:NSStringFromClass([self class])
                                                    code:-1
                                                userInfo:@{NSLocalizedDescriptionKey:@"can not write to file"}];
    }
    @finally {
        return error;
    }
}

@end
