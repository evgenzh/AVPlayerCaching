//
//  NSURL+Tools.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "NSURL+Tools.h"

static NSString *kCustomScheme = @"CustomScheme";
static NSString *kHTTPScheme = @"http";

@implementation NSURL (Tools)
- (NSURL *)urlWithScheme:(NSString *)scheme {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = kCustomScheme;
    return components.URL;
}

- (NSURL *)urlWithCustomScheme {
    return [self urlWithScheme:kCustomScheme];
}

- (NSURL *)urlWithHTTPScheme {
    return [self urlWithScheme:kHTTPScheme];
}

- (BOOL)isCustomSchemeValid {
    return [self.scheme isEqualToString:kCustomScheme];
}

- (BOOL)isHTTPSchemeValid {
    return [self.scheme isEqualToString:kHTTPScheme];
}

@end
