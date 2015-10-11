//
//  ResourceLoader.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol ResourceLoaderDelegate;

@interface ResourceLoader : NSObject <AVAssetResourceLoaderDelegate>
@property (nonatomic, weak) id <ResourceLoaderDelegate> delegate;
- (AVPlayerItem *)createNewPlayerItemWithURL:(NSURL *)url;
- (void)cancelResourceLoadingForURL:(NSURL *)url;
- (void)cancelAllResourceLoadings;
@end

@protocol ResourceLoaderDelegate <NSObject>
@optional
- (void)resourceLoader:(ResourceLoader *)resourceLoader didReceiveBytes:(unsigned long long)bytes totalBytesExpected:(uint64_t)total url:(NSURL *)url;
@end
