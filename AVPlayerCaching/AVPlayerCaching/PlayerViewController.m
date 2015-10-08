//
//  PlayerViewController.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSURL+Tools.h"

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
}

@property (nonatomic, weak) IBOutlet UIToolbar *playerToolBar;
@property (nonatomic, assign) BOOL playing;

@end

@implementation PlayerViewController
- (void)showPlayerWithNewURL:(NSURL *)url {
    if (!_player) {
        [_player removeObserver:self forKeyPath:@"rate"];
    }
    _player = [self playerWithUrl:url];
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    
    [(PlayerView *)self.view setPlayer:_player];

    [self updateToolbarButton];
}

- (AVPlayer *)playerWithUrl:(NSURL *)url {
    return [AVPlayer playerWithURL:url];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        self.playing = (_player.rate > 0);
        [self updateToolbarButton];
    }
}
@end
