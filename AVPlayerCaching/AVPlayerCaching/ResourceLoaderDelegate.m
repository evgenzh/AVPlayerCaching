//
//  ResourceLoaderDelegate.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "ResourceLoaderDelegate.h"
#import "ResourceLoaderItem.h"
#import "ThreadSafeDictionary.h"
#import "CachableData.h"
#import "NSURL+Tools.h"

@interface ResourceLoaderDelegate () <NSURLSessionDataDelegate>
{
    NSURLSession *_session;
}
@property (nonatomic, strong) ThreadSafeDictionary *items;
@end

@implementation ResourceLoaderDelegate
- (instancetype)init {
    self = [super init];
    if (self) {
        self.items = [ThreadSafeDictionary new];
        [self configureURLSession];
    }
    return self;
}

#pragma mark - public
- (AVPlayerItem *)createNewPlayerItemWithURL:(NSURL *)url {
    /// custom scheme makes enabled custom loading of asset resources
    NSURL *customSchemeURL = [url urlWithCustomScheme];
    AVURLAsset *asset = [AVURLAsset assetWithURL:customSchemeURL];
    [asset.resourceLoader setDelegate:self queue:dispatch_queue_create("com.ResourceLoaderDelegate", nil)];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    return item;
}

- (void)removePlayerItemForURL:(NSURL *)url {
    [self cancelResourceLoadingForURL:url];
    [self.items removeObjectForKey:url];
}

#pragma mark - private
- (void)startLoadDataForRequest:(AVAssetResourceLoadingRequest *)request {
    NSURL *url = [request.request.URL urlWithOriginalScheme];
    ResourceLoaderItem *item = self.items[url];
    if (item == nil) {
        CachableData *cahableData = [[CachableData alloc] initWithCachedFileName:url.absoluteString];
        NSData *cachedData = cahableData.availableData;
        NSUInteger requestOffset = cachedData.length;
        NSURLSessionTask *task = [self resumeNewLoadTaskWithURL:url withOffset:requestOffset];
        item = [ResourceLoaderItem itemWithTask:task request:request cache:cahableData];
        self.items[url] = item;
        if (requestOffset > 0) {
            [self respondData:cachedData forURL:url];
        }
    }
}

- (NSURLSessionTask *)resumeNewLoadTaskWithURL:(NSURL *)url withOffset:(NSUInteger)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (offset > 0) {
        NSString *range = @"bytes=";
        range = [range stringByAppendingString:[@(offset) stringValue]];
        range = [range stringByAppendingString:@"-"];
        [request setValue:range forHTTPHeaderField:@"Range"];
    }
    NSURLSessionTask *task = [_session dataTaskWithRequest:request];
    [task resume];
    return task;
}

- (void)cancelResourceLoadingForURL:(NSURL *)url {
    ResourceLoaderItem *item = self.items[url];
    NSURLSessionTask *task = item.task;
    [task cancel];
    [self.items removeObjectForKey:url];
}

- (void)cancelAllResourceLoadings {
    [self.items.allKeys enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cancelResourceLoadingForURL:url];
    }];
}

#pragma mark - resource methods
- (void)fillContentInfoForURL:(NSURL *)url withResponse:(NSURLResponse *)response {
    ResourceLoaderItem *item = self.items[url];
    AVAssetResourceLoadingRequest *request = item.request;
    request.contentInformationRequest.byteRangeAccessSupported = YES;
    request.contentInformationRequest.contentType = response.MIMEType;
    request.contentInformationRequest.contentLength = response.expectedContentLength;
//    NSLog(@"ContentInformationRequest - %@", request.contentInformationRequest);
}

- (void)respondData:(NSData *)data forURL:(NSURL *)url {
    ResourceLoaderItem *item = self.items[url];
    AVAssetResourceLoadingRequest *request = item.request;
    CachableData *cachableData = item.cache;
    [cachableData appendData:data];
//    NSData *cdata = [cachableData readData:request.dataRequest.currentOffset length:data.length];
    if (data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", request.dataRequest);
            [request.dataRequest respondWithData:data];
        });
    }
}

- (void)finishLoadingResourceWithError:(NSError *)error forURL:(NSURL *)url {
    ResourceLoaderItem *item = self.items[url];
    AVAssetResourceLoadingRequest *request = item.request;
    dispatch_async(dispatch_get_main_queue(), ^{
        [request finishLoadingWithError:error];
    });
    if (error) {
        NSLog(@"%@", error);
    }
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self startLoadDataForRequest:loadingRequest];
    return YES;
}

#pragma mark - URLSession
- (void)configureURLSession {
    if (!_session) {
        if (!_session) {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            config.HTTPMaximumConnectionsPerHost = 1;
            config.timeoutIntervalForResource = 0;
            config.timeoutIntervalForRequest = 0;
            _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self fillContentInfoForURL:dataTask.originalRequest.URL withResponse:response];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    // TODO: data caching
    [self respondData:data forURL:dataTask.originalRequest.URL];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)dataTask didCompleteWithError:(NSError *)error {
    // TODO: data storing to cache file
    [self cancelResourceLoadingForURL:dataTask.originalRequest.URL];
    [self finishLoadingResourceWithError:error forURL:dataTask.originalRequest.URL];
}

@end
