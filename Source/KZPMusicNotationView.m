//
//  KZPMusicNotationView.m
//  KZPMusicNotation
//
//  Created by Matt Rankin on 1/10/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//
#import "KZPMusicNotationView.h"

@interface KZPMusicNotationView ()

@property (strong, nonatomic) NSMutableArray *commandQueue;
@property (nonatomic) BOOL loaded;

@end

@implementation KZPMusicNotationView 

- (NSMutableArray *)commandQueue
{
    if (!_commandQueue) _commandQueue = [NSMutableArray array];
    return _commandQueue;
}


#pragma mark - Load -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _loaded = NO;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MusicNotation" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *htmlPath = [bundle pathForResource:@"index" ofType:@"html"];
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    self.delegate = self;
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
#else
    [self setFrameLoadDelegate:self];
    [[self mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
#endif

}


#pragma mark - Javascript -

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (NSString *)callJavascriptMethod:(NSString *)methodName withArguments:(NSArray *)arguments
{
    NSMutableString *methodCall = [NSMutableString stringWithString:methodName];
    [methodCall appendString:@"("];
    for (id arg in arguments) {
        [methodCall appendString:@"\""];
        [methodCall appendString:[[arg description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        [methodCall appendString:@"\""];
        if (arg != [arguments lastObject]) {
            [methodCall appendString:@","];
        }
    }
    [methodCall appendString:@")"];
    return [self stringByEvaluatingJavaScriptFromString:methodCall];
}
#else
- (NSString *)callJavascriptMethod:(NSString *)methodName withArguments:(NSArray *)arguments
{
    return [[[self mainFrame] windowObject] callWebScriptMethod:methodName withArguments:arguments];
}
#endif


#pragma mark - Queue -

- (void)enqueueCommand:(NSDictionary *)command
{
    if (self.loaded) {
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
        returnValue = [self callJavascriptMethod:methodName withArguments:argsOrNull];
    } else {
        returnValue = [self callJavascriptMethod:methodName withArguments:nil];
    }
    [self validateReturnValue:returnValue];
}

- (void)validateReturnValue:(id)returnValue
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if (!returnValue || [returnValue isEqualToString:@""]) {
        [self.musicNotationDelegate notationViewFailedToProcess];
    }
#else
    if (!returnValue || [returnValue isKindOfClass:[WebUndefined class]]) {
        [self.musicNotationDelegate notationViewFailedToProcess];
    }
#endif
    else {
        NSArray *sizeValues = [returnValue componentsSeparatedByString:@","];
        
        // The HTML5 canvas size has already been changed. The return value from the JS function
        // gives an opportunity to resize the webview. However, scrolling ability will be lost
        // if it is resized above the maximum view width for the device.
        CGSize newSize = CGSizeMake([sizeValues[0] intValue], [sizeValues[1] intValue]);
        if (self.maximumSize.width > 0 && newSize.width > self.maximumSize.width) {
            newSize.width = self.maximumSize.width;
        }
        if (self.maximumSize.height > 0 && newSize.height > self.maximumSize.height) {
            newSize.height = self.maximumSize.height;
        }
        
        if (self.shouldAutomaticallyResize) {
            
            // Works in iOS, but has no effecy in OSX. For scenarios where the parent will
            // attempt to resize the webview, set shouldAutomaticallyResize to false.
            CGRect frame = self.frame;
            frame.size = newSize;
            self.frame = frame;
        }
        
        [self.musicNotationDelegate notationViewHasNewContentSize:newSize];
    }
}


#pragma mark - WebView Delegates -

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _loaded = YES;
    [self releaseCommandQueue];
}
#else
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    _loaded = YES;
    [self releaseCommandQueue];
}
#endif


#pragma mark - Public -

- (void)renderNotationString:(NSString *)notationString
{
#if !TARGET_IPHONE_SIMULATOR && !TARGET_OS_IPHONE
    // It appears that iOS handles backslashes slightly differently to OSX when passing strings around
    notationString = [notationString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
#endif
    [self enqueueCommand:@{@"renderVexpaString": @[notationString]}];
}

@end
