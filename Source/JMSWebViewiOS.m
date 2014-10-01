//
//  JMSWebViewiOS.m
//  SchillingerLibrary
//
//  Created by Matt Rankin on 21/09/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import "JMSWebViewiOS.h"
#import "NSString+functions.h"

@implementation JMSWebViewiOS

- (void)resize:(CGSize)size
{
    self.frame = CGRectMake(0, 0, size.width, size.height);
}

- (NSString *)callJavascriptMethod:(NSString *)methodName withArguments:(NSArray *)arguments
{
    NSMutableString *methodCall = [NSMutableString stringWithString:methodName];
    [methodCall appendString:@"("];
    for (id arg in arguments) {
        [methodCall appendString:@"\""];
        [methodCall appendString:[[arg description] trimWhiteSpace]];
        [methodCall appendString:@"\""];
        if (arg != [arguments lastObject]) {
            [methodCall appendString:@","];
        }
    }
    [methodCall appendString:@")"];
    return [self stringByEvaluatingJavaScriptFromString:methodCall];
}

- (void)registerDelegate:(id)delegate
{
    if ([delegate conformsToProtocol:@protocol(UIWebViewDelegate)]) {
        self.delegate = delegate;
    }
}

- (void)loadHTMLFromPath:(NSString *)path
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}

- (BOOL)loaded
{
    return ![self isLoading];
}



@end
