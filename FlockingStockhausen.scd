// OSC SEND
(
~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
~p3.sendMsg("/P3/LeftMargin", 200);
~p3.sendMsg("/P3/RightMargin", 700);
~p3.sendMsg("/P3/TopMargin", 240);
~p3.sendMsg("/P3/BottomMargin", 300);
~p3.sendMsg("/P3/PopulationSize", 8);
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

~


// OSC RECEIVE
OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off

(
~synths = Array.newClear(1000);

SynthDef("starting-SinOsc",
	{
		arg freq = 440, amp = 0.0;
		Out.ar(0, [SinOsc.ar(freq, 0, amp), SinOsc.ar(freq, 0, amp)])
}).send;

~createSynth = {
	arg id;
	~synths.put(id, Synth("starting-SinOsc"));
};

~adjustSynth = {
	arg id, freq, amp;
	~synths[id].set("freq", freq, "amp", amp);
};

~freeSynth = {
	arg id;
	~synths[id].free;
};
~oscCreateSynth = OSCdef.newMatching(\SCCreateSynth, { arg msg, time, addr, recvPort; ~createSynth.value(msg[1]);}, "/SC/CreateSynth");
~oscAdjustSynth= OSCdef.newMatching(\SCAdjustSynth, { arg msg, time, addr, recvPort; ~adjustSynth.value(msg[1], msg[2], msg[3]);}, "/SC/AdjustSynth");
~oscFreeSynth= OSCdef.newMatching(\SCFreeSynth, { arg msg, time, addr, recvPort; ~freeSynth.value(msg[1]);}, "/SC/FreeSynth");
)
~oscCreateSynth.free;
~oscAdjustSynth.free;