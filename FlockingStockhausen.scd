// OSC SEND
(
~size = 10;
~swarmDistance = 50; // default 50
~desiredDistance = 30; // default 30
~areaX = 0;
~areaY = 0;
~areaWidth = 10;
~areaHeight = 10;

~population = 1;


~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 200);
~p3.sendMsg("/P3/AreaY",~population, 0);
~p3.sendMsg("/P3/AreaHeight", ~population, 720);
~p3.sendMsg("/P3/PopulationSize", 0, 0);
~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);

~p3.sendMsg("/P3/FrameRate", 20);
)

// TEMPORAL FUNCTION TO SET POPULATION SIZE
(
~populationGrowth = {
	arg start, finish, step, totalTime;
	var time, steps, p3;

	time = totalTime/((finish - start)/step);
	p3 = NetAddr.new("127.0.0.1", 10001);

	Routine(
	{
			Array.series((finish - start / step)+1, start, step).do(
		{
				arg size;
				p3.sendMsg("/P3/PopulationSize", ~population, size);
					postln(size);
					(time).yield;
		});
})};
)

TempoClock.default.sched(0, ~populationGrowth.value(start:0, finish:0, step:1, totalTime:2));
~populationGrowth.stop;

// OSC RECEIVE
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off

(
~synths = Array.newClear(4000);

SynthDef("point-synth",
	{
		arg freq = 440, amp = 0.0;
		Out.ar(0, [SinOsc.ar(freq, 0, amp), SinOsc.ar(freq, 0, amp)])
}).send;

SynthDef("group-synth",
	{
		arg freq = 440, amp = 0.0;
		Out.ar(0, [SawDPW.ar(freq, 0, amp), SawDPW.ar(freq, 0, amp)])
}).send;

SynthDef("mass-synth",
	{
		arg freq = 440, amp = 0.0;
		Out.ar(0, [PulseDPW.ar(freq, 0.1, amp), PulseDPW.ar(freq, 0.9, amp)])
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
		1, { ~synths.put(id, Synth("group-synth"));},
		2, { ~synths.put(id, Synth("mass-synth")); },
	);
};

~oscCreateSynth = OSCdef.newMatching(\SCCreateSynth, { arg msg, time, addr, recvPort; ~createSynth.value(msg[1]);}, "/SC/CreateSynth");
~oscChangeSynth = OSCdef.newMatching(\SCChangeSynth, { arg msg, time, addr, recvPort; ~changeSynth.value(msg[1],msg[2]);}, "/SC/ChangeSynth");
~oscAdjustSynth= OSCdef.newMatching(\SCAdjustSynth, { arg msg, time, addr, recvPort; ~adjustSynth.value(msg[1], msg[2], msg[3]);}, "/SC/AdjustSynth");
~oscFreeSynth= OSCdef.newMatching(\SCFreeSynth, { arg msg, time, addr, recvPort; ~freeSynth.value(msg[1]);}, "/SC/FreeSynth");


)

~oscCreateSynth.free;
~oscAdjustSynth.free;
~oscFreeSynth.free;