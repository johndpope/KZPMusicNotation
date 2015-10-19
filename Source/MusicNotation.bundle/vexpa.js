var vexpa = {};

vexpa.elementWidths =  {
	"w": 100, 
	"h": 80, 
	"q": 60, 
	"8": 50, 
	"16": 40, 
	"32": 40
};

vexpa.durationStrings = {
	"1": "w", 
	"2": "h", 
	"4": "q", 
	"8": "8", 
	"16": "16", 
	"32": "32"
};

vexpa.durations = {
	"w": 1,
	"h": 2,
	"q": 4,
	"8": 8,
	"16": 16,
	"32": 32
}


//
// Testing
//
vexpa.render = function() {
	var vexpaString = document.getElementById('vexpa').value;
	renderVexpaString(vexpaString);
}


//
// Canvas 
//
function clearCanvas () {
	var canvas = $("#manuscript")[0];
	var ctx = manuscriptContext();
	ctx.save();
	ctx.setTransform(1, 0, 0, 1, 0, 0);
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	ctx.restore();
}

function setCanvasSize(width, height) {
	var canvas = $("#manuscript")[0];
	canvas.width = width;
	canvas.height = height;
}

function manuscriptContext(width, height) {
	var canvas = $("#manuscript")[0];
	var renderer = new Vex.Flow.Renderer(canvas, Vex.Flow.Renderer.Backends.CANVAS);
	var ctx = renderer.getContext();
	return ctx;
}


//
// Vexflow format and draw
//
function drawScore(bars, beams, staveNotes) {
	var ctx = manuscriptContext();

	// Bars (staves)
	for (var i = 0; i < bars.length; i++) {
		if (bars[i].voice.isPercussionStave) {
			convertStaveToPercussion(bars[i]);	
		} 
		bars[i].setContext(ctx).draw();
		bars[i].voice.draw(ctx, bars[i]);

		if (bars[i].connectedStave) {
			new Vex.Flow.StaveConnector(
				bars[i].connectedStave.bar, bars[i]
			).setType(Vex.Flow.StaveConnector.type.SINGLE_LEFT).setContext(ctx).draw();
			new Vex.Flow.StaveConnector(
			    bars[i].connectedStave.bar, bars[i]
			).setType(Vex.Flow.StaveConnector.type.SINGLE_RIGHT).setContext(ctx).draw();
		}
	}

	// Beams
	for (var i = 0; i < beams.length; i++) {
		beams[i].setContext(ctx).draw();
	}

	// Ties
	for (var i = 0; i < staveNotes.length; i++) {
		if (staveNotes[i].isTied && (i < staveNotes.length - 1)) {
			var indices = [];
			for (var n = 0; n < staveNotes[i].keys.length; n++) {
				indices.push(n);
			}			
			var tie = new Vex.Flow.StaveTie({
				first_note: staveNotes[i],
				last_note: staveNotes[i+1],
				first_indices: indices,
				last_indices: indices
			});
			tie.setContext(ctx).draw();
		}
	}	
}


//
// Vexpa
//
function renderVexpaString(vexpaString) {
    
    if (!vexpaString || vexpaString.length === 0) {
        clearCanvas();
        return;
    }
    
	var staveStrings = vexpaString.split("\\");
	var ctx = manuscriptContext();
	var voices = [];
	var bars = [];
	var staves = [];
	var beams = [];
	var staveNotes = [];
	var scoreWidth = 0;

	for (var i = 0; i < staveStrings.length; i++) {
		var staveData = renderStaveString(staveStrings[i].trim());
		staves.push(staveData.voices);
		beams = beams.concat(staveData.beams);
		staveNotes = staveNotes.concat(staveData.staveNotes);
	}

	var barWidths = new Array(staves[0].length);

	// Get all bar widths
	for (var i = 0; i < staves.length; i++) {
		for (var j = 0; j < staves[i].length; j++) {
			var voice = staves[i][j];
			if (voice.barWidth > barWidths[j] || !barWidths[j]) {
				barWidths[j] = voice.barWidth;
			}
		}
	}

	// Format all bars
	var yPosition = 0;
	for (var i = 0; i < staves.length; i++) {
		var xPosition = 10;
		for (var j = 0; j < staves[i].length; j++) {
			var voice = staves[i][j];
			var width = barWidths[j];
			var bar = new Vex.Flow.Stave(xPosition, yPosition, width);
			bar.voice = voice;
			voice.bar = bar;
			bars.push(bar);
			if (i == 0) {
				scoreWidth += width;
			}			
			xPosition += width;
			if (i > 0) {
				bar.connectedStave = staves[i-1][j];	
			}
			if (voice.isPercussionStave && j == 0) {
				bar.addClef("percussion");
			} else {
				if (voice.clef) {
					bar.addClef(voice.clef);
				}
				if (voice.keysig) {
					bar.addKeySignature(voice.keysig);
				}				
			}	
			if (voice.timesig) {
				bar.addTimeSignature(voice.timesig);
			}
			new Vex.Flow.Formatter().formatToStave([voice], bar, {alignRests: true});
		}
		if (staves[i][0].isPercussionStave) {
			yPosition += 70;
		} else {
			yPosition += 100;
		}		
	}

	setCanvasSize(scoreWidth+50, yPosition+50);	
	drawScore(bars, beams, staveNotes);
	return [scoreWidth+50, yPosition+50].toString();
}


//
// Stave (handle clef)
//
function renderStaveString(staveString) {
	var barStrings = staveString.split("|");
	var voices = [];
	var beams = [];
	var staveNotes = [];
	var isPercussionStave = false;
	var activeClef = "treble";

	var maxHeight = 0;

	for (var i = 0; i < barStrings.length; i++) {
		if (barStrings[i].trim() != "") {
			var barData = renderBarString(barStrings[i].trim(), activeClef);
			var voice = barData.voice;
			if (voice.clef) {
				activeClef = voice.clef;
			}
			voices.push(voice);
			beams = beams.concat(barData.beams);
			staveNotes = staveNotes.concat(barData.staveNotes);
			isPercussionStave = isPercussionStave || barData.isPercussion;
		}
	}

	for (var i = 0; i < voices.length; i++) {
		voices[i].isPercussionStave = isPercussionStave;
	}

	return {
		voices: voices,
		beams: beams,
		staveNotes: staveNotes,
	};
}

function convertStaveToPercussion(stave) {
	for (var i = 0; i < 5; i++) {
		if (i == 2) continue;
		stave.setConfigForLine(i, {visible: false} );
	}	
}


//
// Bar (handle T/S)
//
function renderBarString(barString, activeClef) {
	
	var groupStrings = barString.split("'");
	var barNotes = [];
	var beams = [];
	var barWidth = 0;
	var minBeatValue = 0;
	var totalDuration = 0.0;
	var barWidth = 0;
	var isPercussionBar = false;
	var staveSettings = {};

	for (var i = 0; i < groupStrings.length; i++) {
		if (groupStrings[i].trim() != "") {
			var clef = staveSettings.clef ? staveSettings.clef : activeClef;
			var groupData = renderGroupString(groupStrings[i].trim(), clef);
			$.extend(staveSettings, groupData.settings);
			barNotes = barNotes.concat(groupData.staveNotes);
			beams = beams.concat(groupData.beams);
			if (groupData.minBeatValue > minBeatValue) {
				minBeatValue = groupData.minBeatValue;
			}
			totalDuration += groupData.totalDuration;
			barWidth += groupData.groupWidth;
			isPercussionBar = isPercussionBar || groupData.isPercussion;
		}
	}

	var voice = new Vex.Flow.Voice({
		num_beats: totalDuration * minBeatValue,
		beat_value: minBeatValue,
		resolution: Vex.Flow.RESOLUTION
	});

	voice.addTickables(barNotes);
	voice.barWidth = barWidth;
	voice.clef = staveSettings.clef;
	voice.keysig = staveSettings.keysig;
	voice.timesig = staveSettings.timesig;

	return {
		voice: voice,
		beams: beams,
		staveNotes: barNotes,
		isPercussion: isPercussionBar
	};
}


//
// Group
//
function renderGroupString(groupString, activeClef) {
	var staveNoteStrings = groupString.split(" ");
	var groupNotes = [];
	var beamNotes = [];
	var beams = [];
	var minBeatValue = 0;
	var totalDuration = 0.0;
	var groupWidth = 0;
	var isPercussionGroup = false;
	var staveSettings = {};

	for (var i = 0; i < staveNoteStrings.length; i++) {

		if (staveNoteStrings[i].indexOf('=') === -1) {
			var clef = staveSettings.clef ? staveSettings.clef : activeClef;
			var staveNote = parseStaveNoteString(staveNoteStrings[i], clef);

			isPercussionGroup = isPercussionGroup || staveNote.isUnpitched;

			groupNotes.push(staveNote);
			groupWidth += vexpa.elementWidths[staveNote.duration];

			var duration = vexpa.durations[staveNote.duration];
			if (duration > minBeatValue	) {
				minBeatValue = duration;
			}
			totalDuration += (1/duration) * (staveNote.isDotted == true ? 1.5 : 1.0);

			if (duration > 4) {
				beamNotes.push(staveNote);
			} else {
				if (beamNotes.length > 1) {
					beams.push(new Vex.Flow.Beam(beamNotes));
				}
				beamNotes = [];
			}
		} else {
			if (parseSettingString(staveNoteStrings[i]).clef) {
				staveSettings.clef = parseSettingString(staveNoteStrings[i]).clef;
			}
			if (parseSettingString(staveNoteStrings[i]).keysig) {
				staveSettings.keysig = parseSettingString(staveNoteStrings[i]).keysig;
			}
			if (parseSettingString(staveNoteStrings[i]).timesig) {
				staveSettings.timesig = parseSettingString(staveNoteStrings[i]).timesig;
			}			
		}

	}

	if (beamNotes.length > 1) {
		beams.push(new Vex.Flow.Beam(beamNotes));
	}
	
	return {
		settings: staveSettings,
		beams: beams,
		staveNotes: groupNotes,
		minBeatValue: minBeatValue,
		totalDuration: totalDuration,
		groupWidth: groupWidth,
		isPercussion: isPercussionGroup
	};
}

function parseSettingString(settingString) {
	var settingElements = settingString.split("=");
	if (settingElements[0] == "Q") {
		return {clef: settingElements[1]};
	}
	if (settingElements[0] == "T") {
		return {timesig: settingElements[1]};
	}
	if (settingElements[0] == "K") {
		return {keysig: settingElements[1]};
	}
}


//
// StaveNote (maybe be pitch/duration, duration, or pitch)
//
function parseStaveNoteString(staveNoteString, clef) {
	var staveNoteElements = staveNoteString.split("/");
	var durationData;
	var notes;
	var durationOnly = false;
	var pitchOnly = false;
	var isRest = false;

	if (staveNoteElements.length == 1) {
		var firstChar = staveNoteElements[0].charAt(0);
		firstChar = firstChar.replace(/\D/g,'');		
		if (firstChar.length == 0) {
			pitchOnly = true;
		} else {
			durationOnly = true;
		}
	} else if (staveNoteElements[0] === "r") {
		isRest = true;
	}

	if (durationOnly) {
		notes = ["b/4"];
		durationData = parseDuration(staveNoteElements[0], isRest);
	} else if (pitchOnly) {
		notes = parseNotes(staveNoteElements[0]);
		durationData = {durString: "w", isTied: false};
	} else {
		if (isRest) {
			notes = ["b/4"];
		} else {
			notes = parseNotes(staveNoteElements[0]);	
		}
		durationData = parseDuration(staveNoteElements[1], isRest);
	}

	var staveNote = new Vex.Flow.StaveNote({
		keys: notes,
		duration: durationData.durString,
		clef: clef
	});

	if (durationOnly) {
		staveNote.isUnpitched = true;
	}

	applyAccidentals(staveNote);

	if (durationData.isDotted) {
		staveNote.isDotted = true;
		staveNote.addDotToAll();
	}

	if (durationData.isTied) {
		staveNote.isTied = true;
	}

	return staveNote;
}


//
// Accidental modifiers
//
function applyAccidentals(staveNote) {
	for (var i = 0; i < staveNote.keyProps.length; i++) {
		var accidental = staveNote.keyProps[i].accidental;
		if (accidental) {
			staveNote.addAccidental(i, new Vex.Flow.Accidental(accidental));
		}
	}
}


//
// Chord
//
function parseNotes(chordString) {
	var noteStrings = chordString.split("+");
	var notes = [];
	for (var i = 0; i < noteStrings.length; i++) {
		var vexNote = parseNote(noteStrings[i]);
		notes.push(vexNote);
	}
	return notes;
}


//
// Note
//
function parseNote(noteString) {
	var noteName = noteString.charAt(0);
	var register = noteString.slice(-1);
	var accidental = noteString.charAt(1);
	if (accidental !== register) {
		switch (accidental) {
			case "B": accidental = "bb"; break;
			case "x": accidental = "##"; break;
		}
	} else {
		accidental = "";
	}
	return noteName + accidental + "/" + register;
}


//
// Duration
//


function parseDuration(durationString, isRest) {

	var dotted = (durationString.indexOf(".") > -1);
	var tied = (durationString.indexOf("^") > -1);

	dur = durationString.replace(/\D/g,'');
	var vexDurationString = vexpa.durationStrings[dur];	

	if (dotted) {
		vexDurationString += "d";
	}

	if (isRest) {
		vexDurationString += "r";
	}

	return {
		durString: vexDurationString,
		isTied: tied,
		isDotted: dotted
	}
}
