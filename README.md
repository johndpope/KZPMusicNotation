[![Build Status](https://travis-ci.org/kazoompah/KZPMusicNotation.svg?branch=master)](https://travis-ci.org/kazoompah/KZPMusicNotation)

KZPMusicNotation 
============

Add a simple musical notation widget to any iOS or OSX app. This project leverages the [vexflow](http://www.vexflow.com/) library by 0xFE, for drawing music directly onto an HTML5 canvas.

Installation
------------

Add the following 2 lines to your pod file:

	pod 'KZPUtilities', :git => 'https://github.com/kazoompah/KZPUtilities.git'
	pod 'KZPMusicNotation', :git => 'https://github.com/kazoompah/KZPMusicNotation.git'	

It is not available via the public cocoa pods repo at the moment.

Setup 
------

1. Create a UIWebView (iOS) or WebView (OSX) in interface builder
2. Set the web view's custom class to `KZPMusicNotationView`
3. Wire up the web view to your view controller

Optionally, you can also do the following:

- Assign the controller as delegate to receive `notationViewFailedToProcess` and `notationViewHasNewContentSize` callbacks
- Set the music notation view to automatically resize using the `shouldAutomaticallyResize` property. This is useful if the result is being displayed in a popover, for example.
- Specify the maximum size for the notation view using the `maximumSize` property. This does not restrict the size of the  web view's canvas, which will become scrollable if larger than `maximumSize`.

Usage Example
--------------

To render music notation, call 'renderNotationString' on the KZPMusicNotationView object, like so:

	[self.musicNotationView renderNotationString:@"Q=treble T=4/4 K=F C4/4 Cx4/8 Eb4/8 ' F4/8 AB4/8 ' Ab4/4 | Eb4/8 D4/8^ ' D4/8 C4/8 ' Ab3/8 Eb3+G3+C4/4. \\\\ Q=bass T=4/4 K=F Eb3+G3/2 C3/2 | F#2/2^ F#2/8 C2/4."];

The string above contains examples of all the possibilities available at present. (Note that `\\\\` is the unfortunate escape sequence for a single `\`). It is sufficient for situations requiring pitch and duration representation.


