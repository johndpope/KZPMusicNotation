//
//  KZPMusicKeyboardTranslator.m
//  KZPMusicPad
//
//  Created by Matt Rankin on 5/01/2015.
//  Copyright (c) 2015 Sudoseng. All rights reserved.
//

#import "KZPMusicKeyboardTranslator.h"
#import "NSArray+functions.h"
#import "NSString+functions.h"
#import "KZPMusicSciNotation.h"

@interface KZPMusicKeyboardTranslator ()

@property (strong, nonatomic) KZPMusicNotationView *musicNotation;
@property (strong, nonatomic) NSMutableArray *vexpaComponents;

@end

@implementation KZPMusicKeyboardTranslator

- (instancetype)initWithNotationView:(KZPMusicNotationView *)notationView
{
    if (!notationView) {
        NSLog(@"Error: translator must be initialised with existing notation view");
        return nil;
    }
    
    self = [super init];
    if (self) {
        _musicNotation = notationView;
        _musicNotation.musicNotationDelegate = self;
        _vexpaComponents = [NSMutableArray array];
    }
    return self;
}

// TODO: does not take scores into account
- (void)render
{
    [self.musicNotation renderNotationString:[self.vexpaComponents oneLineDescriptionUsingDelimiter:@" "]];
}

- (void)setMusicNotation:(KZPMusicNotationView *)musicNotation
{
    _musicNotation = musicNotation;    
    _musicNotation.musicNotationDelegate = self;
}

- (void)reset
{
    _vexpaComponents = [NSMutableArray array];
}


#pragma mark - KZPMusicNotationDelegate -

- (void)notationViewFailedToProcess
{
    NSLog(@"Error: bad vexpa string");
}

- (void)notationViewHasNewContentSize:(CGSize)size
{
//    NSLog(@"notation view did resize");
}


#pragma mark - KZPMusicKeyboardDelegate -

// TODO: the last component may be a clef or key or time signature, which doesn't gel with
// the JMSDataObject vexpa parsing, and causes a mysterious extra deletion to be required
// when clearing a notation view.
- (void)keyboardDidSendBackspace
{
    [self.vexpaComponents removeLastObject];
    [self render];
}

- (void)keyboardDidSendSignal:(NSArray *)noteID
                     spelling:(NSArray *)spelling
                     duration:(NSNumber *)duration
                       dotted:(BOOL)dotted
                         tied:(BOOL)tied
{
    NSMutableString *vexpaString = [NSMutableString string];
    if (noteID) {
        NSMutableString *vexpaNoteOrChord = [NSMutableString string];
        for (int i = 0; i < [noteID count]; i++) {
            NSString *vexpaPitch = [KZPMusicSciNotation sciNotationForPitch:[noteID[i] intValue]
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
    
    NSLog(@"vexpa components: %@", self.vexpaComponents);
    [self render];
}

- (NSString *)getString
{
    // Clean up the string by getting rid of display data like time sig and clef
    NSMutableArray *parsableComponents = [NSMutableArray array];
    for (NSString *vexpaComponent in self.vexpaComponents) {
        
        // Be a little more sophisticated here...
        if (![vexpaComponent contains:@"="]) {
            [parsableComponents addObject:vexpaComponent];
        }
    }
    return [parsableComponents count] > 0 ? [parsableComponents oneLineDescriptionUsingDelimiter:@" "] : @"";
}

// TODO: does not take scores into account
- (void)applyComponentsFromVexpaString:(NSString *)vexpaString
{
    self.vexpaComponents = [NSMutableArray arrayWithArray:[vexpaString componentsSeparatedByString:@" "]];
    [self render];
}

@end
