//
//  NSURL+Tools.m
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import "NSURL+Tools.h"

static NSString *kCustomScheme = @"CustomScheme";

@implementation NSURL (Tools)
- (NSURL *)urlWithScheme:(NSString *)scheme {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = [scheme stringByAppendingString:components.scheme];
    return components.URL;
}

- (NSURL *)urlWithOriginalScheme {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = [components.scheme stringByReplacingOccurrencesOfString:kCustomScheme withString:@""];
    return components.URL;
}

- (NSURL *)urlWithCustomScheme {
    return [self urlWithScheme:kCustomScheme];
}

- (BOOL)isCustomSchemeValid {
    return [self.scheme rangeOfString:kCustomScheme].length > 0;
}

@end
