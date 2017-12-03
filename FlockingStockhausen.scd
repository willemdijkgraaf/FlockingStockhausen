// OSC SEND
(
~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
~p3.sendMsg("/P3/LeftMargin", 100);
~p3.sendMsg("/P3/RightMargin", 500);
~p3.sendMsg("/P3/TopMargin", 50);
~p3.sendMsg("/P3/BottomMargin", 500);
~p3.sendMsg("/P3/PopulationSize", 100);
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

o = OSCdef.newMatching(\SCCreateSynth, { arg msg, time, addr, recvPort; 'CreateSynth received'.postln;}, "/SC/CreateSynth");
o.free;