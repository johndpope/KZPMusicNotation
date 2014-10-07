//
//  KZPAppDelegate.m
//  KZPMusicNotationOSX
//
//  Created by Matt Rankin on 7/10/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import "KZPAppDelegate.h"

@implementation KZPAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.canvas.musicNotationDelegate = self;
    self.canvas.shouldAutomaticallyResize = NO;
}

- (IBAction)textFieldChanged:(id)sender {
    NSTextField *textField = (NSTextField *)sender;
    if ([textField.stringValue length] > 0) {
        [self.canvas renderNotationString:textField.stringValue];
    }
}


#pragma mark - KZPMusicNotationDelegate -

- (void)notationViewHasNewContentSize:(CGSize)size
{
    // Do something with the new content size
}

- (void)notationViewFailedToProcess
{
    NSLog(@"failed to process: %@", self.textField.stringValue);
}

@end
