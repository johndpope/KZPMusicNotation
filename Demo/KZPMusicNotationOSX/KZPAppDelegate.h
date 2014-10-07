//
//  KZPAppDelegate.h
//  KZPMusicNotationOSX
//
//  Created by Matt Rankin on 7/10/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KZPMusicNotationView.h"

@interface KZPAppDelegate : NSObject <NSApplicationDelegate, KZPMusicNotationViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet KZPMusicNotationView *canvas;
@property (weak) IBOutlet NSTextField *textField;
- (IBAction)textFieldChanged:(id)sender;

@end
