//
//  SciNotation.h
//  Schillinger
//
//  Created by Matt Rankin on 12/03/2014.
//  Copyright (c) 2014 Matt Rankin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SciNotation : NSObject

+ (NSString *)sciNotationForPitch:(int)pitch;
+ (NSString *)vexFlowNotationForPitch:(int)pitch;
+ (int)pitchValueForSciNotation:(NSString *)sciNotation;

+ (NSString *)noteNameForPitch:(int)pitch;
+ (NSString *)noteOctaveForPitch:(int)pitch;
+ (NSString *)noteModifierForPitch:(int)pitch;

@end
