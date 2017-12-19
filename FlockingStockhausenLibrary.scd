// COMPOSITION LIBRARY FOR Flocking Stockhausen
(
~synths = Array.newClear(4000);
~p3 = NetAddr.new("127.0.0.1", 10001);

// Define Synths

SynthDef("point-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 0);
		Out.ar(0, [SinOsc.ar(freq, 0, amp) * gen, SinOsc.ar(freq, 0, amp) * gen ])
}).send;

SynthDef("group-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 0);
		Out.ar(0, [SawDPW.ar(freq, 0, amp) * gen , SawDPW.ar(freq, 0, amp) * gen ])
}).send;

SynthDef("mass-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 0);
		Out.ar(0, [PulseDPW.ar(freq, 0.1, amp) * gen, PulseDPW.ar(freq, 0.9, amp) * gen])
}).send;

// Incoming OSC message handling
~createSynth = {
	arg id;
	~synths.put(id, Synth("point-synth"));
};

~adjustSynth = {
	arg id, freq, amp;
	~synths[id].set("freq", freq, "amp", amp);
};

~freeSynth = {
	arg id;
	~synths[id].free;
};

~changeSynth = {
	arg id, type;
	~synths[id].free;
	switch (type,
		0, { ~synths.put(id, Synth("point-synth")); },
		1, { ~synths.put(id, Synth("group-synth")); },
		2, { ~synths.put(id, Synth("mass-synth")); },
	);
};

~oscCreateSynth = OSCdef.newMatching(\SCCreateSynth, { arg msg, time, addr, recvPort; ~createSynth.value(msg[1]);}, "/SC/CreateSynth");
~oscChangeSynth = OSCdef.newMatching(\SCChangeSynth, { arg msg, time, addr, recvPort; ~changeSynth.value(msg[1],msg[2]);}, "/SC/ChangeSynth");
~oscAdjustSynth= OSCdef.newMatching(\SCAdjustSynth, { arg msg, time, addr, recvPort; ~adjustSynth.value(msg[1], msg[2], msg[3]);}, "/SC/AdjustSynth");
~oscFreeSynth= OSCdef.newMatching(\SCFreeSynth, { arg msg, time, addr, recvPort; ~freeSynth.value(msg[1]);}, "/SC/FreeSynth");


// Compositional functions

// GENERIC TEMPORAL RANGE CHANGE
~temporalRangeChange = {
	arg
	    when,
	    populationId,
		from,
		to,
		step,
		duration,
		oscCommand;
	var interval, arrayStep, seriesSize;

	if (from < to,
		{
			interval = duration/((to - from)/step);
			seriesSize = (to - from / step)+1;
			arrayStep = step;
		}, // else
		{
			interval = duration/((from - to)/step);
			seriesSize = (from - to / step)+1;
			arrayStep = step * -1;
	    });
	SystemClock.sched(when,
		Routine(
			{
				Array.series(seriesSize, from, arrayStep).do(
					{
						arg value;
						~p3.sendMsg(oscCommand , ~population, value);
						(interval).yield;
					});
			}
		)
	 );
};

// PLAY
~playComposition = {
	arg score;
	score.do({
		arg ...arguments;
		var function = arguments[0][0], args = arguments[0][1];
		function.valueArray(args);
	});
};

// POPULATION
~createPopulation = {
	arg
		when,
		size,
		swarmDistance,
		desiredDistance,
		x, y,
		width, height;
	SystemClock.sched(
		when,
			Routine(
			{
				~p3.sendMsg(
					"/P3/CreatePopulation",
					size,
					swarmDistance,
					desiredDistance,
					x, y,
					width, height);
				0.yield;
			})
	);
};

~changePopulation = {
	arg
		when = 0,
		duration = 0.5,
		which = 0,
		start,
		finish,
		step;
	~temporalRangeChange.value(
		when: when,
		populationId: which,
		from:start,
		to:finish,
		step:step,
		duration:duration,
		oscCommand: "/P3/PopulationSize"
	);
};

// TEMPO
~changeTempo = {
	arg
		when = 0,
		duration = 0.5,
		start,
		finish,
		step;

	~temporalRangeChange.value(
		when: when,
		populationId:0,
		from:start,
		to:finish,
		step:step,
		duration:duration,
		oscCommand:"/P3/FrameRate"
	);
};

// POSITION
~moveHorizontally = {
	arg
		when,
		duration,
		which,
		fromX,
		toX,
		step;

	~temporalRangeChange.value(
		when: when,
		populationId:which,
		from:fromX,
		to:toX,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaX"
	);
};

~moveVertically = {
	arg
		when,
		duration,
		which,
		fromY,
		toY,
		step;

	~temporalRangeChange.value(
		when:when,
		populationId:which,
		from:fromY,
		to:toY,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaY"
	);
};

// AREA SIZE
~changeWidth = {
	arg
		when,
		duration,
		which,
		fromWidth,
		toWidth,
		step;

	~temporalRangeChange.value(
		when: when,
		populationId:which,
		from:fromWidth,
		to:toWidth,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaWidth"
	);
};

~changeHeight = {
	arg
		when,
		duration,
		which,
		fromHeight,
		toHeight,
		step;

	~temporalRangeChange.value(
		when: when,
		populationId:which,
		from:fromHeight,
		to:toHeight,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaWidth"
	);
};
)