[![Build Status](https://travis-ci.org/kazoompah/KZPMusicNotation.svg?branch=master)](https://travis-ci.org/kazoompah/KZPMusicNotation)

KZPMusicNotation 
============

Easily add a simple musical notation widget to any iOS or OSX app. This project leverages the [vexflow](http://www.vexflow.com/) library by 0xFE, for drawing music directly onto the HTML5 canvas. Thus, by contributing to that project you will automatically improve this one!

Installation
------------

Add the following 2 lines to your pod file:

	pod 'KZPUtilities', :git => 'https://github.com/kazoompah/KZPUtilities.git'
	pod 'KZPMusicNotation', :git => 'https://github.com/kazoompah/KZPMusicNotation.git'	

It is not available via the public cocoa pods repo, yet.

Setup 
------

1. Create a UIWebView (iOS) or WebView (OSX) in interface builder
2. Set the web view's custom class to 'KZPMusicNotationView'
3. Wire up the web view to your view controller

Optionally, you can also do the following:

- Assign the controller as delegate to receive 'notationViewFailedToProcess' and 'notationViewHasNewContentSize' callbacks
- Set the music notation view to automatically resize using the 'shouldAutomaticallyResize' property. This is useful if the result is being displayed in a popover, for example.
- Specify the maximum size for the notation view using the 'maximumSize' property. Note that this sets the limit for the *web view*, but the entire canvas will still render and will become scrollable if large enough.

Usage Example
--------------

To render music notation, call 'renderNotationString' on the KZPMusicNotationView object. An example is:

	[self.musicNotationView renderNotationString:@"C4/4"];

The string above contains all the current possibilities available at present. It is sufficient for situations requiring pitch and duration representation, but that's about it. Wanna help me extend it? =D


