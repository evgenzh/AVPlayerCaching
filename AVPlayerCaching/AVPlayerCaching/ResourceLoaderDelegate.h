//
//  ResourceLoader.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 09.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface ResourceLoader : NSObject <AVAssetResourceLoader>
- (AVPlayerItem *)createNewPlayerItemWithURL:(NSURL *)url;
- (void)cancelResourceLoadingForURL:(NSURL *)url;
- (void)cancelAllResourceLoadings;
@end
