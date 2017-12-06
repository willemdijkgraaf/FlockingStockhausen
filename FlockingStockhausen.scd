// SCORE
(
~score = [
	//createPopualtion  size:  swarmDist desiredDist x    y     width height
	[~createPopulation, 0,     50,       30,         0,   50,   10,   100],
	[~createPopulation, 0,     50,       30,         0,   650,  10,   70],

	//changePopulation  which: when: duration: start: finish: stepSize:
	[~changePopulation, [0,     5,    4,        0,     10,     1]],
	[~changePopulation, [1,     5,    4,        0,     10,     2]]

];

~playComposition.value(~score);
)







// TESTS
(
~size = 10;
~swarmDistance = 50; // default 50
~desiredDistance = 30; // default 30
~areaX = 0;
~areaY = 0;
~areaWidth = 10;
~areaHeight = 10;


)
(
~population = 0;
~population = 1;

~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 1200);
~p3.sendMsg("/P3/AreaY",~population, 620);
~p3.sendMsg("/P3/AreaHeight", ~population, 100);
~p3.sendMsg("/P3/PopulationSize", 0, 0);

~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);

~p3.sendMsg("/P3/FrameRate", 50);
)
