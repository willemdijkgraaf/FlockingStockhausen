// OSC SEND
(
~population = 0;
~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 200);
~p3.sendMsg("/P3/AreaY",~population, 160);
~p3.sendMsg("/P3/AreaHeight", ~population, 50);
~p3.sendMsg("/P3/PopulationSize", ~population, 1);

~p3.sendMsg("/P3/FrameRate", 60);
)

// TEMPORAL FUNCTION TO SET POPULATION SIZE
(
~populationGrowth = Routine(
	{
		[10,20,30,20,10,0].do(
		{
				arg size;
				~p3.sendMsg("/P3/PopulationSize", size);
				10.yield;
		});
});
)

~populationGrowth.next;
TempoClock.default.sched(0, ~populationGrowth);
~populationGrowth.stop;

// OSC RECEIVE
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off

(
~synths = Array.newClear(1000);

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