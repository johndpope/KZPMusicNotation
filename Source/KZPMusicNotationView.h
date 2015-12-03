//
//  KZPMusicNotationView.h
//  KZPMusicNotation
//
//  Created by Matt Rankin on 1/10/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <WebKit/WebKit.h>
#endif

@protocol KZPMusicNotationViewDelegate <NSObject>

- (void)notationViewHasNewContentSize:(CGSize)size;
- (void)notationViewFailedToProcess;

@end

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
@interface KZPMusicNotationView : UIWebView <UIWebViewDelegate>
#else
@interface KZPMusicNotationView : WebView <WebFrameLoadDelegate>
#endif

@property (weak, nonatomic) id<KZPMusicNotationViewDelegate> musicNotationDelegate;
@property (nonatomic) BOOL shouldAutomaticallyResize;
@property (nonatomic) CGSize maximumSize;

- (void)renderNotationString:(NSString *)notationString;

@end
