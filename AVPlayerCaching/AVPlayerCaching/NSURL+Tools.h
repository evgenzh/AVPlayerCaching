//
//  NSURL+Tools.h
//  AVPlayerCaching
//
//  Created by Eugene Zhuk Work on 08.10.15.
//  Copyright © 2015 Eugene Zhuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Tools)
- (NSURL *)urlWithCustomScheme;
- (NSURL *)urlWithOriginalScheme;
- (BOOL)isCustomSchemeValid;
- (BOOL)isHTTPSchemeValid;
@end
