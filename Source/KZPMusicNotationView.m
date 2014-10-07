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
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/Vexpa/index.html"];
    
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
    if (![self isLoading]) {
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
        CGSize newSize = CGSizeMake([sizeValues[0] intValue], [sizeValues[1] intValue]);
        if (self.shouldAutomaticallyResize) {
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
    [self releaseCommandQueue];
}
#else
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self releaseCommandQueue];
}
#endif


#pragma mark - Public -

- (void)renderNotationString:(NSString *)notationString
{
    [self enqueueCommand:@{@"renderVexpaString": @[notationString]}];
}

@end
