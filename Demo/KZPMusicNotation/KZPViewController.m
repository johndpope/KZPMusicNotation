//
//  KZPViewController.m
//  KZPMusicNotation
//
//  Created by Matt Rankin on 21/09/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import "KZPViewController.h"
#import "KZPMusicNotationView.h"

@interface KZPViewController () <KZPMusicNotationViewDelegate>

@property (weak, nonatomic) IBOutlet KZPMusicNotationView *canvas;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation KZPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canvas.musicNotationDelegate = self;
    self.canvas.shouldAutomaticallyResize = NO;
    [self.textField addTarget:self action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)sender
{
    [self.canvas renderNotationString:sender.text];
}


#pragma mark - KZPMusicNotationDelegate -

- (void)notationViewFailedToProcess
{
    NSLog(@"Failed to process string: %@", self.textField.text);
}

- (void)notationViewHasNewContentSize:(CGSize)size
{
    // Do something with the new content size
}

@end
