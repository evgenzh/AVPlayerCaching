//
//  PlayerViewController.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "PlayerViewController.h"
#import "ResourceLoaderDelegate.h"

@interface PlayerView : UIView
@property (nonatomic, retain) AVPlayer *player;
@end

@implementation PlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)self.layer player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)self.layer setPlayer:player];
}
@end

@interface PlayerViewController ()
{
    AVPlayer *_player;
    ResourceLoaderDelegate *_resourceLoader;
}

@property (nonatomic, weak) IBOutlet UIToolbar *playerToolBar;
@property (nonatomic, assign) BOOL playing;

@end

@implementation PlayerViewController
- (void)showPlayerWithNewURL:(NSURL *)url {
    [self preparePlayerWithURL:url];
    self.playing = NO;
    [self updateToolbarButton];
}

- (void)preparePlayerWithURL:(NSURL *)url {
    if (_resourceLoader == nil) {
        _resourceLoader = [ResourceLoaderDelegate new];
    }
    
    [_resourceLoader cancelAllResourceLoadings];
    
    AVPlayerItem *playerItem = [_resourceLoader createNewPlayerItemWithURL:url];
    if (_player == nil) {
        //TODO: M3U8 handling
        _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [(PlayerView *)self.view setPlayer:_player];
    } else {
        [_player replaceCurrentItemWithPlayerItem:playerItem];
    }
}

#pragma mark - observing
- (void)addObservers {
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        self.playing = (_player.rate > 0);
        [self updateToolbarButton];
    }
}

#pragma mark - UI

- (void)updateToolbarButton {
    UIBarButtonSystemItem btnType = self.playing ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: btnType target:self action:@selector(playPause)];
    self.playerToolBar.items = [NSArray arrayWithObject:item];
}

- (void)playPause {
    if (self.playing) {
        [_player pause];
    } else {
        [_player play];
    }
}

@end
