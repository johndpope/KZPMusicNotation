//
//  JMSNotationViewer.m
//  SchillingerLibrary
//
//  Created by Matt Rankin on 21/09/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import "JMSConsole.h"
#import "JMSNotationViewer.h"
#if !(TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <WebKit/WebKit.h>
#endif


@interface JMSNotationViewer ()

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
<UIWebViewDelegate>
#endif

{
    int _rhythmicResolution;
}

@property (strong, nonatomic) id<JMSWebViewInterface> webView;
@property (strong, nonatomic) NSMutableArray *commandQueue;

@end


@implementation JMSNotationViewer

@synthesize rhythmicResolution = _rhythmicResolution;

- (NSMutableArray *)commandQueue
{
    if (!_commandQueue) _commandQueue = [NSMutableArray array];
    return _commandQueue;
}

- (id)initWithWebView:(id<JMSWebViewInterface>)webView
{
    self = [super init];
    if (self) {
        _webView = webView;
        NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
        NSString *htmlPath = [resourcesPath stringByAppendingString:@"/Vexflow/index.html"];
        [_webView registerDelegate:self];
        [_webView loadHTMLFromPath:htmlPath];
    }
    return self;
}

- (void)setRhythmicResolution:(int)rhythmicResolution
{
    _rhythmicResolution = rhythmicResolution;
}

- (void)enqueueCommand:(NSDictionary *)command
{
    if ([self.webView loaded]) {
        [self executeJavascriptCommand:command];
    } else {
        [self.commandQueue addObject:command];
    }
}

- (void)releaseCommandQueue
{
    while ([self.commandQueue count] > 0) {
        [self executeJavascriptCommand:self.commandQueue[0]];
        [self.commandQueue removeObjectAtIndex:0];
    }
}

- (void)executeJavascriptCommand:(NSDictionary *)command
{
    NSString *methodName = [[command allKeys] lastObject];
    NSString *returnValue;
    id argsOrNull = [command valueForKey:methodName];
    if ([argsOrNull isKindOfClass:[NSArray class]]) {
        returnValue = [self.webView callJavascriptMethod:methodName withArguments:argsOrNull];
    } else {
        returnValue = [self.webView callJavascriptMethod:methodName withArguments:nil];
    }
    if (returnValue && ![returnValue isEqualToString:@""]) {
        [self resizeWebview:returnValue];
    } else {
        [[JMSConsole console] logError:[NSString stringWithFormat:@"Failed to process notation string: %@", argsOrNull] withException:nil forInput:nil referenceID:nil];
    }
}

- (void)resizeWebview:(NSString *)sizeString
{
    NSArray *sizeValues = [sizeString componentsSeparatedByString:@","];
    int width = [sizeValues[0] intValue];
    int height = [sizeValues[1] intValue];
    CGSize newSize = CGSizeMake(width, height);
    [self.webView resize:newSize];
    [self.delegate readyWithManuscriptSize:newSize];
}


#pragma mark - JMSMusicNotationInterface -

- (void)showDefault
{
    [self.commandQueue addObject:@{@"renderVexpaString": @[@"c4 e4 g#4 c5 \\\\ f4 f4 f4 f4 \\\\ b4 f#5 b4 f#5"]}];
}

- (void)renderVexpaString:(NSString *)vexpaString
{
    NSLog(@"vexpaString: %@", vexpaString);
    [self.commandQueue addObject:@{@"renderVexpaString": @[vexpaString]}];
}
     

#pragma mark - WebView Delegates -
     
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self releaseCommandQueue];
}
#else
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self releaseCommandQueue];
}
#endif

@end
