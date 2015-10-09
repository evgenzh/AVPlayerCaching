//
//  ResourceLoaderDelegate.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface ResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>
- (AVPlayerItem *)createNewPlayerItemWithURL:(NSURL *)url;
- (void)cancelResourceLoadingForURL:(NSURL *)url;
- (void)cancelAllResourceLoadings;
@end
