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

// TEMPORAL RANGE CHANGE
~temporalRangeChange = {
	arg
	    populationId,
		from,
		to,
		step,
		duration,
		oscCommand;
	var time, arrayStep, seriesSize;

	if (from < to,
		{
			time = duration/((to - from)/step);
			seriesSize = (to - from / step)+1;
			arrayStep = step;
		},
		{
			time = duration/((from - to)/step);
			seriesSize = (from - to / step)+1;
			arrayStep = step * -1;
	    });

	Routine(
	{
		Array.series(seriesSize, from, arrayStep).do(
		{
				arg value,time;
				~p3.sendMsg(oscCommand , ~population, value);
				(time).yield;
		});
})};

// PLAY
~playComposition = {
	arg score;
	score.do({
		arg ...arguments;
		var function = arguments[0][0], args = arguments[0][1];

		postln(arguments[0][0]);
		postln(arguments[0][1]);

		function.valueArray(args);
	});
};

// POPULATION
~temporalPopulationCreate = {
	arg
		size,
		swarmDistance,
		desiredDistance,
		x, y,
		width, height;

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
		});
};

~populationCreate = {
	arg
		when,
		size,
		swarmDistance,
		desiredDistance,
		x, y,
		width, height;
	postln(when);
	TempoClock.default.sched(
		when,
		~temporalPopulationCreate.value(
			size,
			swarmDistance,
			desiredDistance,
			x, y,
			width, height));

};

~changePopulation = {
	arg
		when = 0,
		duration = 0.5,
		which = 0,
		start,
		finish,
		step;
	TempoClock.default.sched(when, ~temporalRangeChange.value(
		populationId: which,
		start:start,
		finish:finish,
		step:step,
		duration:duration,
		oscCommand: "/P3/PopulationSize"
	));
};

// TEMPO
~changeTempo = {
	arg
		when = 0,
		duration = 0.5,
		start,
		finish,
		step;

	TempoClock.default.sched(when, ~temporalRangeChange.value(
		populationId:0,
		start:start,
		finish:finish,
		step:step,
		duration:duration,
		oscCommand:"/P3/FrameRate"
	));
};

// POSITION
~changeHorizontally = {
	arg
		when = 0,
		duration = 0.5,
		which = 0,
		fromX,
		toX,
		step;

	TempoClock.default.sched(when, ~temporalRangeChange.value(
		populationId:which,
		from:fromX,
		to:toX,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaX"
	));
};

~changeVertically = {
	arg
		when = 0,
		duration = 0.5,
		which = 0,
		fromY,
		toY,
		step;

	TempoClock.default.sched(when, ~temporalRangeChange.value(
		populationId:which,
		from:fromY,
		to:toY,
		step:step,
		duration:duration,
		oscCommand:"/P3/AreaY"
	));
};
)