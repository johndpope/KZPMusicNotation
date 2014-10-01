//
//  JMSNotationViewer.h
//  SchillingerLibrary
//
//  Created by Matt Rankin on 21/09/2014.
//  Copyright (c) 2014 Sudoseng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMSWebViewInterface.h"
#import "JMSMusicNotationInterface.h"

@protocol JMSNotationViewerDelegate <NSObject>

- (void)readyWithManuscriptSize:(CGSize)size;

@end

@interface JMSNotationViewer : NSObject <JMSMusicNotationInterface>

@property (weak, nonatomic) id<JMSNotationViewerDelegate> delegate;

- (id)initWithWebView:(id<JMSWebViewInterface>)webView;
- (void)setRhythmicResolution:(int)rhythmicResolution;

@end
