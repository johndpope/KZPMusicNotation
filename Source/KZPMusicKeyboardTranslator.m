//
//  KZPMusicKeyboardTranslator.m
//  KZPMusicPad
//
//  Created by Matt Rankin on 5/01/2015.
//  Copyright (c) 2015 Sudoseng. All rights reserved.
//

#import "KZPMusicKeyboardTranslator.h"
#import "NSArray+functions.h"
#import "SciNotation.h"

@interface KZPMusicKeyboardTranslator ()

@property (strong, nonatomic) NSMutableArray *vexpaComponents;

@end

@implementation KZPMusicKeyboardTranslator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _vexpaComponents = [NSMutableArray array];
    }
    return self;
}

- (void)render
{
    [self.musicNotation renderNotationString:[self.vexpaComponents oneLineDescriptionUsingDelimiter:@" "]];
}


#pragma mark - KZPMusicNotationDelegate -

- (void)notationViewFailedToProcess
{
    NSLog(@"Error: bad vexpa string");
}

- (void)notationViewHasNewContentSize:(CGSize)size
{
    NSLog(@"notation view did resize");
}


#pragma mark - KZPMusicKeyboardDelegate -

- (void)keyboardDidSendBackspace
{
    [self.vexpaComponents removeLastObject];
    [self render];
}

- (void)keyboardWasDismissed
{
    
}

- (void)keyboardDidSendSignal:(NSArray *)noteID
                    inputType:(NSArray *)type
                     spelling:(NSArray *)spelling
                     duration:(NSNumber *)duration
                       dotted:(BOOL)dotted
                         tied:(BOOL)tied
                   midiPacket:(NSArray *)MIDI
                    oscPacket:(NSArray *)OSC
{
    NSMutableString *vexpaString = [NSMutableString string];
    if (noteID) {
        NSMutableString *vexpaNoteOrChord = [NSMutableString string];
        for (int i = 0; i < [noteID count]; i++) {
            NSString *vexpaPitch = [SciNotation sciNotationForPitch:[noteID[i] intValue]
                                                           modifier:[spelling[i % [spelling count]] intValue]
                                                            resolve:YES];
            if ([vexpaNoteOrChord length] > 0) {
                [vexpaNoteOrChord appendString:@"+"];
            }
            [vexpaNoteOrChord appendString:vexpaPitch];
        }
        if ([vexpaNoteOrChord length] > 0) {
            [vexpaString appendFormat:@"%@", vexpaNoteOrChord];
        }
    }
    
    if (duration) {
        if (!noteID) {
            if ([duration intValue] < 0) {
                [vexpaString appendString:@"r/"];
            }
        } else {
            [vexpaString appendString:@"/"];
        }
        [vexpaString appendFormat:@"%d", abs([duration intValue])];
        
        if (dotted) {
            [vexpaString appendString:@"."];
        }
        
        if (tied) {
            [vexpaString appendString:@"^"];
        }
    }
    
    [self.vexpaComponents addObject:[NSString stringWithString:vexpaString]];
    [self render];
}

@end
