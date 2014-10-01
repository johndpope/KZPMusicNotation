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

- (void)awakeFromNib
{
    self.delegate = self;
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/Vexflow/index.html"];
    [self loadHTMLFromPath:htmlPath];
}

- (void)loadHTMLFromPath:(NSString *)path
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}


#pragma mark - Javascript -

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
    if (!returnValue || [returnValue isEqualToString:@""]) {
        NSLog(@"Failed to process notation string: %@", argsOrNull);
    }
}


#pragma mark - UIWebViewDelegate -

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self releaseCommandQueue];
}


#pragma mark - Public -

- (void)renderNotationString:(NSString *)notationString
{
    [self enqueueCommand:@{@"renderVexpaString": @[notationString]}];
}

@end
