//
//  KZPMusicNotationView.h
//  KZPMusicNotation
//
//  Created by Matt Rankin on 1/10/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KZPMusicNotationView : UIWebView <UIWebViewDelegate>

- (void)renderNotationString:(NSString *)notationString;

@end
