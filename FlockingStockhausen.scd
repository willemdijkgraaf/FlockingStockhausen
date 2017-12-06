// OSC SEND
(
~size = 10;
~swarmDistance = 50; // default 50
~desiredDistance = 30; // default 30
~areaX = 0;
~areaY = 0;
~areaWidth = 10;
~areaHeight = 10;

~population = 0;

~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 1200);
~p3.sendMsg("/P3/AreaY",~population, 670);
~p3.sendMsg("/P3/AreaHeight", ~population, 40);
~p3.sendMsg("/P3/PopulationSize", 0, 10);

~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);

~p3.sendMsg("/P3/FrameRate", 50);

~changePopulation.value(which: ~population, when: 0, time: 4, start: 0, finish: 132, step: 1); // increase over time
~changePopulation.value(which: ~population, when: 0, time: 4, start: 5, finish: 0, step: 1); // decrease over time

)

// ALL BASIC FUNCTIONALITY STARTS HERE
(
~synths = Array.newClear(4000);

SynthDef("point-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 2);
		Out.ar(0, [SinOsc.ar(freq, 0, amp) * gen, SinOsc.ar(freq, 0, amp) * gen ])
}).send;

SynthDef("group-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 2);
		Out.ar(0, [SawDPW.ar(freq, 0, amp) * gen , SawDPW.ar(freq, 0, amp) * gen ])
}).send;

SynthDef("mass-synth",
	{
		arg freq = 440, amp = 0.0;
		var env = Env.adsr(0.05, 0.1, 0.1);
		var gen = EnvGen.kr(env, 1, doneAction: 2);
		Out.ar(0, [PulseDPW.ar(freq, 0.1, amp) * gen, PulseDPW.ar(freq, 0.9, amp) * gen])
}).send;

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
		0,   { ~synths.put(id, Synth("point-synth")); },
		1, { ~synths.put(id, Synth("group-synth")); },
		2, { ~synths.put(id, Synth("mass-synth")); },
	);
};

~oscCreateSynth = OSCdef.newMatching(\SCCreateSynth, { arg msg, time, addr, recvPort; ~createSynth.value(msg[1]);}, "/SC/CreateSynth");
~oscChangeSynth = OSCdef.newMatching(\SCChangeSynth, { arg msg, time, addr, recvPort; ~changeSynth.value(msg[1],msg[2]);}, "/SC/ChangeSynth");
~oscAdjustSynth= OSCdef.newMatching(\SCAdjustSynth, { arg msg, time, addr, recvPort; ~adjustSynth.value(msg[1], msg[2], msg[3]);}, "/SC/AdjustSynth");
~oscFreeSynth= OSCdef.newMatching(\SCFreeSynth, { arg msg, time, addr, recvPort; ~freeSynth.value(msg[1]);}, "/SC/FreeSynth");

// TEMPORAL FUNCTION TO SET POPULATION SIZE
~temporalPopulationChange = {
	arg populationId, start, finish, step, period;
	var time, steps, p3, seriesSize, arrayStep;
	if (start < finish,
		{
			time = period/((finish - start)/step);
			seriesSize = (finish - start / step)+1;
			arrayStep = step;
		},
		{
			time = period/((start - finish)/step);
			seriesSize = (start - finish / step)+1;
			arrayStep = step * -1;
	    });

	p3 = NetAddr.new("127.0.0.1", 10001);

	Routine(
	{
			Array.series(seriesSize, start, arrayStep).do(
		{
				arg size;
				p3.sendMsg("/P3/PopulationSize", populationId, size);
					postln(size);
					(time).yield;
		});
})};

~changePopulation = {
	arg which, when, time, start, finish, step;
	TempoClock.default.sched(when, ~temporalPopulationChange.value(which: which, start:start, finish:finish, step:step, period:time));
};
)

~oscCreateSynth.free;
~oscAdjustSynth.free;
~oscFreeSynth.free;

// OSC RECEIVE
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off