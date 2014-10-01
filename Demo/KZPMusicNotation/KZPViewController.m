//
//  KZPViewController.m
//  KZPMusicNotation
//
//  Created by Matt Rankin on 21/09/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import "KZPViewController.h"
#import "KZPMusicNotationView.h"

@interface KZPViewController ()

@property (weak, nonatomic) IBOutlet KZPMusicNotationView *canvas;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation KZPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.textField addTarget:self action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)sender
{
    [self.canvas renderNotationString:sender.text];
}



@end
