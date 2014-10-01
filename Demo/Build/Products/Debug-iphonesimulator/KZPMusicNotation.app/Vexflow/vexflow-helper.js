//
// Testing
//
function render() {
	var vexpaString = document.getElementById('vexpa').value;
	renderVexpaString(vexpaString);
}


//
// Canvas 
//
var ELEMENT_WIDTHS =  {
	"w": 100, 
	"h": 80, 
	"q": 60, 
	"8": 50, 
	"16": 40, 
	"32": 40
};

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
		if (bars[i].isPercussionStave) {
			convertStaveToPercussion(bars[i]);	
		} 
		bars[i].setContext(ctx).draw();
		bars[i].voice.draw(ctx, bars[i]);

		if (bars[i].connectedStave) {
			new Vex.Flow.StaveConnector(bars[i].connectedStave, bars[i]).setType(Vex.Flow.StaveConnector.type.SINGLE).setContext(ctx).draw();				
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
	var staveStrings = vexpaString.split("\\");
	var ctx = manuscriptContext();
	var bars = [];
	var staves = [];
	var beams = [];
	var staveNotes = [];
	var staveWidth = 0;
	var yPosition = 10;

	for (var i = 0; i < staveStrings.length; i++) {
		var staveData = renderStaveString(staveStrings[i].trim(), yPosition);
		bars = bars.concat(staveData.bars);
		staves.push(bars);
		beams = beams.concat(staveData.beams);
		staveNotes = staveNotes.concat(staveData.staveNotes);
		if (staveData.staveWidth > staveWidth) {
			staveWidth = staveData.staveWidth;
		} 
		if (i > 0) {
			staveData.bars[0].connectedStave = staves[i-1][0];	
		}
		yPosition += 100;
	}

	setCanvasSize(staveWidth+50, yPosition+50);	
	drawScore(bars, beams, staveNotes);
	return [staveWidth+50, yPosition+50].toString();
}


//
// Stave (handle clef)
//
function renderStaveString(staveString, yPosition) {
	var barStrings = staveString.split("|");
	var bars = []; // staves
	var xPosition = 10;
	var voices = [];
	var beams = [];
	var staveNotes = [];
	var isPercussionStave = false;

	var maxHeight = 0;

	for (var i = 0; i < barStrings.length; i++) {
		var origin = {
			x: xPosition,
			y: yPosition
		};
		var barData = renderBarString(barStrings[i].trim(), origin);
		var bar = barData.bar;
		bars.push(bar);
		xPosition += barData.bar.width;
		voices.push(barData.voice);
		beams = beams.concat(barData.beams);
		staveNotes = staveNotes.concat(barData.staveNotes);
		isPercussionStave = isPercussionStave || barData.isPercussion;
	}

	for (var i = 0; i < bars.length; i++) {
		bars[i].isPercussionStave = isPercussionStave;
	}

	return {
		bars: bars,
		beams: beams,
		staveNotes: staveNotes,
		staveWidth: xPosition
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
function renderBarString(barString, origin) {
	// check for TS/clef later

	var groupStrings = barString.split("'");
	var barNotes = [];
	var beams = [];
	var barWidth = 0;
	var minBeatValue = 0;
	var totalDuration = 0.0;
	var barWidth = 0;
	var isPercussionBar = false;

	for (var i = 0; i < groupStrings.length; i++) {
		var groupData = renderGroupString(groupStrings[i].trim());
		barNotes = barNotes.concat(groupData.staveNotes);
		beams = beams.concat(groupData.beams);
		if (groupData.minBeatValue > minBeatValue) {
			minBeatValue = groupData.minBeatValue;
		}
		totalDuration += groupData.totalDuration;
		barWidth += groupData.groupWidth;
		isPercussionBar = isPercussionBar || groupData.isPercussion;
	}

	var bar = new Vex.Flow.Stave(origin.x, origin.y, barWidth);

	var voice = new Vex.Flow.Voice({
		num_beats: totalDuration * minBeatValue,
		beat_value: minBeatValue,
		resolution: Vex.Flow.RESOLUTION
	});

	voice.addTickables(barNotes);
	new Vex.Flow.Formatter().formatToStave([voice], bar, {alignRests: true});
	bar.voice = voice;

	return {
		bar: bar,
		beams: beams,
		staveNotes: barNotes,
		isPercussion: isPercussionBar
	};
}


//
// Group
//
function renderGroupString(groupString) {
	var staveNoteStrings = groupString.split(" ");
	var groupNotes = [];
	var beamNotes = [];
	var beams = [];
	var minBeatValue = 0;
	var totalDuration = 0.0;
	var groupWidth = 0;
	var isPercussionGroup = false;

	for (var i = 0; i < staveNoteStrings.length; i++) {

		var staveNote = parseStaveNoteString(staveNoteStrings[i]);

		isPercussionGroup = isPercussionGroup || staveNote.isUnpitched;

		groupNotes.push(staveNote);
		groupWidth += ELEMENT_WIDTHS[staveNote.duration];

		var duration = DURATIONS[staveNote.duration];
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
	}

	if (beamNotes.length > 1) {
		beams.push(new Vex.Flow.Beam(beamNotes));
	}
	
	return {
		beams: beams,
		staveNotes: groupNotes,
		minBeatValue: minBeatValue,
		totalDuration: totalDuration,
		groupWidth: groupWidth,
		isPercussion: isPercussionGroup
	};
}


//
// StaveNote (maybe be pitch/duration, duration, or pitch)
//
function parseStaveNoteString(staveNoteString) {
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
		duration: durationData.durString
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
			case "&": accidental = "bb"; break;
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
var DURATION_STRINGS = {
	"1": "w", 
	"2": "h", 
	"4": "q", 
	"8": "8", 
	"16": "16", 
	"32": "32"
};

var DURATIONS = {
	"w": 1,
	"h": 2,
	"q": 4,
	"8": 8,
	"16": 16,
	"32": 32
}

function parseDuration(durationString, isRest) {

	var dotted = (durationString.indexOf(".") > -1);
	var tied = (durationString.indexOf("^") > -1);

	dur = durationString.replace(/\D/g,'');
	var vexDurationString = DURATION_STRINGS[dur];	

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
