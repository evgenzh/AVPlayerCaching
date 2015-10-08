//
//  ViewController.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

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
    
}

- (IBAction)playPlaylist {
    
}

@end
