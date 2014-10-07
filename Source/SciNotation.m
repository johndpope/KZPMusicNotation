//
//  SciNotation.m
//  Schillinger
//
//  Created by Matt Rankin on 12/03/2014.
//  Copyright (c) 2014 Matt Rankin. All rights reserved.
//

#import "SciNotation.h"

static int noteNameOffsets[7] = {0, 2, 4, 5, 7, 9, 11};
static int accidentalModifiers[5] = {1, 1, -1, -2, 2};

@implementation SciNotation

// Does not take into account any information about chromatic identity.
// TODO: define JMSNote to take into account diatonic ID and accidental.

// TODO: remove and do all intermediate work in the type classes themselves
+ (NSString *)sciNotationForPitch:(int)pitch
{
    NSArray *noteDescriptions = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    return [NSString stringWithFormat:@"%@%d", noteDescriptions[pitch % 12], (pitch / 12) - 1];
}

+ (NSString *)vexFlowNotationForPitch:(int)pitch
{
    NSArray *noteDescriptions = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    return [NSString stringWithFormat:@"%@/%d", noteDescriptions[pitch % 12], (pitch / 12) - 1];
}

+ (int)pitchValueForSciNotation:(NSString *)sciNotation
{
    sciNotation = [sciNotation capitalizedString];
    
    NSMutableArray *components = [[NSMutableArray alloc] init];
    for (int i=0; i < [sciNotation length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [sciNotation characterAtIndex:i]];
        [components addObject:ichar];
    }
    
    NSString *noteID = components[0];
    NSString *modifier;
    int octave;
    if ([components count] == 2) {
        octave = [components[1] intValue];
    } else {
        modifier = components[1];
        octave = [components[2] intValue];
    }
    
    NSArray *noteNames = @[@"C", @"D", @"E", @"F", @"G", @"A", @"B"];
    NSArray *accidentals = @[@"#", @"+", @"-", @"_", @"x"];
    
    return noteNameOffsets[[noteNames indexOfObject:noteID]] + (octave+1)*12 + (modifier ? accidentalModifiers[[accidentals indexOfObject:modifier]] : 0);
}

+ (NSString *)noteNameForPitch:(int)pitch
{
    NSArray *noteDescriptions = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    return [noteDescriptions[pitch % 12] substringToIndex:1];
}

+ (NSString *)noteOctaveForPitch:(int)pitch
{
    return [NSString stringWithFormat:@"%u", (pitch / 12) - 1];
}

+ (NSString *)noteModifierForPitch:(int)pitch
{
    NSArray *noteDescriptions = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
    if ([noteDescriptions[pitch % 12] length] > 1) {
        return [noteDescriptions[pitch % 12] substringFromIndex:1];
    }
    return nil;
}


@end
