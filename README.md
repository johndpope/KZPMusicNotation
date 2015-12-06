[![Build Status](https://travis-ci.org/kazoompah/KZPMusicNotation.svg?branch=master)](https://travis-ci.org/kazoompah/KZPMusicNotation)

KZPMusicNotation 
============

Add a simple musical notation widget to any iOS or OSX app. This project leverages the [vexflow](http://www.vexflow.com/) library by [0xFE](http://0xfe.blogspot.com.au/), in this case for drawing music directly onto an HTML5 canvas.

Installation
------------

The best way to add this to a project is to use Cocoapods. Add the following 2 lines to your Podfile, then run `pod install`:

	pod 'KZPUtilities', :git => 'https://github.com/kazoompah/KZPUtilities.git'
	pod 'KZPMusicNotation', :git => 'https://github.com/kazoompah/KZPMusicNotation.git'	

The project is not available via the public cocoa pods repo at the moment.

Setup 
------

1. Create a `UIWebView` (iOS) or `WebView` (OSX) in interface builder
2. Set the web view's custom class to `KZPMusicNotationView`
3. Wire up the web view to your view controller (don't forget to `#import "KZPMusicNotationView.h"`)

Optionally, you can also do the following:

- Assign the controller as delegate to receive `notationViewFailedToProcess` and `notationViewHasNewContentSize:` callbacks
- Set the music notation view to automatically resize using the `shouldAutomaticallyResize` property. This is useful if the result is being displayed in a popover, for example.
- Specify the maximum size for the notation view using the `maximumSize` property. This does not restrict the size of the  web view's canvas, which will become scrollable if larger than `maximumSize`.

Demo
----

The repository contains a project with demo apps for both iOS and OSX, so you can troubleshoot your setup or experiment with various notation strings. (Run `pod install` after cloning to grab the utilities library)

Usage Example
--------------

To render music notation, call `renderNotationString` on the `KZPMusicNotationView` object, like so:
```objective-c
	[self.musicNotationView renderNotationString:@"Q=treble T=4/4 K=F C4/4 Cx4/8 Eb4/8 ' F4/8 AB4/8 ' Ab4/4 | Eb4/8 D4/8^ ' D4/8 C4/8 ' Ab3/8 Eb3+G3+C4/4. \\\\ Q=bass T=4/4 K=F Eb3+G3/2 C3/2 | F#2/2^ F#2/8 C2/4."];
```
	
The result looks like this:	
	
![alt text](https://github.com/kazoompah/KZPMusicNotation/blob/master/example.png "Example output")	
	
The notation string above contains examples of all the possibilities available at present. Hopefully this can serve as a reference to get started. (Note that `\\\\` is the unfortunate escape sequence for a single `\`). The syntax is sufficient for situations requiring pitch and duration representation.


