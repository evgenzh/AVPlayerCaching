//
//  PlayerViewController.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "PlayerViewController.h"
#import "ResourceLoader.h"

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

@interface PlayerViewController () <ResourceLoaderDelegate>
{
    AVPlayer *_player;
    ResourceLoader *_resourceLoader;
}

@property (nonatomic, weak) IBOutlet UIToolbar *playerToolBar;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
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
        _resourceLoader = [ResourceLoader new];
        _resourceLoader.delegate = self;
    }
    
    [_resourceLoader cancelAllResourceLoadings];
    
    AVPlayerItem *playerItem = [_resourceLoader createNewPlayerItemWithURL:url];
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [(PlayerView *)self.view setPlayer:_player];
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

#pragma mark - ResourceLoaderDelegate
- (void)resourceLoader:(ResourceLoader *)resourceLoader didReceiveBytes:(unsigned long long)bytes totalBytesExpected:(uint64_t)total url:(NSURL *)url {
    if (total > 0) {
        float percent = ((float)bytes * 100/total);
        self.infoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"bytes received: (%.4f%%) ", nil), percent];
    }
}

#pragma mark - UI
- (void)updateToolbarButton {
    UIBarButtonSystemItem btnType = self.playing ? UIBarButtonSystemItemPause : UIBarButtonSystemItemPlay;
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 10;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: btnType target:self action:@selector(playPause)];
    self.playerToolBar.items = @[space, item];
}

- (void)playPause {
    if (self.playing) {
        [_player pause];
    } else {
        [_player play];
    }
}

@end
