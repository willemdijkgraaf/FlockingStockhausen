// SCORE
(
~score = [
	//createPopulation  when: size:  swarmDist desiredDist x    y     width height
	[~createPopulation, [1,       1,     50,            30,             300,   200,   300,   40]],
	//[~createPopulation, [3,       20,    50,            30,             0,   150, 200,   150]],
	//[~createPopulation, [3,       8,    50,            30,             400,   600, 800,   120]],

	//changePopulation  when: duration: which: start: finish: stepSize:
	[~changePopulation, [5,       20,          0,       1,       20,     1]],
	//[~changePopulation, [0,       10,          1,       1,       20,     1]],

	// moveHorizontally when: duration: which: fromX: toX: step:
	//[~moveHorizontally, [0,      1,            2,        400,     0,    1]],

	// changeVertically when: duration: which: fromY: toY: step:
	//[~moveVertically,    [0,      5,             1,       200,    0,    1]],

	// changeTempo when: duration: from: to:   step:
	[~changeTempo, [25,      10,            60,       0,  1]]
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

~p3.sendMsg("/P3/AreaX", 0, 40.0);
~p3.sendMsg("/P3/AreaWidth", 0, 900);
~p3.sendMsg("/P3/AreaY",0, 400.0);
~p3.sendMsg("/P3/AreaHeight", 0, 50);
~p3.sendMsg("/P3/PopulationSize", 1, 10);

~p3.sendMsg("/P3/CreatePopulation", ~size, ~swarmDistance, ~desiredDistance, ~areaX, ~areaY, ~areaWidth, ~areaHeight);
~p3.sendMsg("/P3/FrameRate", 60);
)
