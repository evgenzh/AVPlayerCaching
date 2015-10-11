//
//  ViewController.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

#define VIDEO_URL [NSURL URLWithString:@"http://sample-videos.com/video/mp4/720/big_buck_bunny_720p_50mb.mp4"]
#define M3U8_URL [NSURL URLWithString:@""]

@interface ViewController ()
@property (nonatomic, weak) PlayerViewController *playerController;
@end

@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"playerVC"]) {
        self.playerController = segue.destinationViewController;
    }
}

- (IBAction)playURL {
    [self.playerController showPlayerWithNewURL:VIDEO_URL];
}

- (IBAction)playPlaylist {
    [self.playerController showPlayerWithNewURL:M3U8_URL];
}

@end
