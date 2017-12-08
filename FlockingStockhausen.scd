// SCORE
(
~score = [
	//createPopualtion  when: size:  swarmDist desiredDist x    y     width height
	[~createPopulation, 1,       10,     50,            30,             0,   50,   100,   70],
	//[~createPopulation, 3,       20,    50,            30,             0,   150, 200,   150],

	//changePopulation  when: duration: which: start: finish: stepSize:
	[~changePopulation, [5,       10,          1,       10,        0,     1]],
	//[~changePopulation, [5,       12,          2,       20,        200, 1]]
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
~areaWidth = 100;
~areaHeight = 100;


)
(
~population = 0;
~population = 1;
~population = 2;

~p3.sendMsg("/P3/AreaX", ~population, 10);
~p3.sendMsg("/P3/AreaWidth", ~population, 200);
~p3.sendMsg("/P3/AreaY",~population, 10);
~p3.sendMsg("/P3/AreaHeight", ~population, 10);
~p3.sendMsg("/P3/PopulationSize", ~population, 100);

~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);

~p3.sendMsg("/P3/FrameRate", 50);
)
