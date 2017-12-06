import java.util.LinkedList;
import oscP5.*;
import netP5.*;

OscP5 _osc;

int _clock;
int _groupMembershipUpdateRate;
Synth _synth;

Population[] _populations = new Population[0];

void setup() {

  size(1280, 720);
  frameRate(40);

  _groupMembershipUpdateRate = 10;
  
  NetAddress remoteLocation = new NetAddress("127.0.0.1",57120);
  _osc = new OscP5(this, 10001);
  _synth = new Synth(_osc, remoteLocation);
  
}

void createPopulation(int populationSize, float swarmDistance, float desiredDistance, Area area){
  int newLength = _populations.length + 1;
  int id = _populations.length;
  Population population = new Population(id, populationSize, swarmDistance, desiredDistance, area, _synth);
  _populations = (Population[])expand(_populations, newLength);
  _populations[id] = population;
}

void draw() {
  if (mousePressed) {
  }

  _clock++;
  if (_clock % _groupMembershipUpdateRate == 1) {
    // reset group membership, groupsizes & apply behaviors
    for (Population population : _populations) {
      population.updateGroupMembership();
    }
  }

  background(60);

  for (Population population : _populations) {
      population._area.draw();
      population.draw();
    }
  
}

void oscEvent(OscMessage theOscMessage) {
  println(theOscMessage);
  
  // Left Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaX") && theOscMessage.checkTypetag("ii") ) {
    int populationId = theOscMessage.get(0).intValue();
    int x = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setX(x);
    return;
  }
  
  // Right Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaWidth") && theOscMessage.checkTypetag("ii") ) {
    int populationId = theOscMessage.get(0).intValue();
    int myWidth = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setWidth(myWidth);
    return;
  }
  
  // Top Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaY") && theOscMessage.checkTypetag("ii") ) {
    int populationId = theOscMessage.get(0).intValue();
    int y = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setY(y);
    return;
  }
  
  // Bottom Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaHeight") && theOscMessage.checkTypetag("ii") ) {
    int populationId = theOscMessage.get(0).intValue();
    int myHeight = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setHeight(myHeight);
    return;
  }
  
  // Population size
  if (theOscMessage.checkAddrPattern("/P3/PopulationSize") && theOscMessage.checkTypetag("ii") ) { //<>//
    int populationId = theOscMessage.get(0).intValue();
    int populationSize = theOscMessage.get(1).intValue();
    _populations[populationId].setPopulationSize(populationSize);
    println(populationId + " " + populationSize);
    return;
  }
  
   if (theOscMessage.checkAddrPattern("/P3/PopulationSize") && theOscMessage.checkTypetag("if") ) {
    int populationId = theOscMessage.get(0).intValue();
    int populationSize = (int)theOscMessage.get(1).floatValue();
    _populations[populationId].setPopulationSize(populationSize);
    println(populationId + " " + populationSize);
    return;
  }
  
  // Frame rate
  if (theOscMessage.checkAddrPattern("/P3/FrameRate") && theOscMessage.checkTypetag("i") ) {
    int rate = theOscMessage.get(0).intValue();
    if (rate > 60) return;
    frameRate(rate);
    return;
  }
  
  // Create population
  if (theOscMessage.checkAddrPattern("/P3/CreatePopulation") && theOscMessage.checkTypetag("iiiiiii") ) {
    int populationSize = theOscMessage.get(0).intValue();
    int swarmDistance = theOscMessage.get(1).intValue();
    int desiredDistance = theOscMessage.get(2).intValue();
    int areaX = theOscMessage.get(3).intValue();
    int areaY = theOscMessage.get(4).intValue();
    int areaWidth = theOscMessage.get(5).intValue();
    int areaHeight = theOscMessage.get(6).intValue();
    
    Area area = new Area(areaX, areaY, areaWidth, areaHeight);
    createPopulation(populationSize, (float)swarmDistance, (float)desiredDistance, area);
    return;
  }
}