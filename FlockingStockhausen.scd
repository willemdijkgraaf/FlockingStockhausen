// SCORE
(
~score = [
	//                   which: when: duration: start: finish: stepSize:
	[~changePopulation, [0,     0,    4,        0,     10,     1]],
	[~changePopulation, [1,     5,    4,        0,     10,     2]]

];

~playComposition.value(~score);
)








(
~size = 10;
~swarmDistance = 50; // default 50
~desiredDistance = 30; // default 30
~areaX = 0;
~areaY = 0;
~areaWidth = 10;
~areaHeight = 10;

~p3 = NetAddr.new("127.0.0.1", 10001);    // create the NetAddr for the processing sketch
)
(
~population = 0;
~population = 1;

~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 1200);
~p3.sendMsg("/P3/AreaY",~population, 620);
~p3.sendMsg("/P3/AreaHeight", ~population, 100);
~p3.sendMsg("/P3/PopulationSize", 1, 0);

~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);

~p3.sendMsg("/P3/FrameRate", 50);
)
