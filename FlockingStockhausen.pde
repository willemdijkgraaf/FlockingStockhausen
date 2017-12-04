import java.util.LinkedList;
import oscP5.*;
import netP5.*;

OscP5 _osc;

int _clock;
int _groupMembershipUpdateRate;
Area _margins;
Population[] _populations = new Population[2];

void setup() {

  size(1280, 720);
  frameRate(40);

  
  
  _groupMembershipUpdateRate = 10;
  
  NetAddress remoteLocation = new NetAddress("127.0.0.1",57120);
  _osc = new OscP5(this, 10001);
  Synth synth = new Synth(_osc, remoteLocation);
  
  int initialPopulationSize = 50;
  float swarmDistance = 50;
  float desiredDistance = 30;
  
  float y = 5;
  float h = (height - 10);
  float x = 5;
  float w = (width/2) - 10;
  _margins = new Area(x,y,w,h);
  _populations[0] = new Population(0, initialPopulationSize, swarmDistance, desiredDistance, _margins, synth);
 
  y = 5;
  h = (height - 10);
  x = (width/2);
  w = (width/2) - 10;
  _margins = new Area(x,y,w,h);
  _populations[1] = new Population(1, initialPopulationSize, swarmDistance, desiredDistance, _margins, synth);
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
  // Left Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaX") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int x = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setX(x);
    return;
  }
  
  // Right Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaWidth") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int myWidth = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setWidth(myWidth);
    return;
  }
  
  // Top Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaY") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int y = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setY(y);
    return;
  }
  
  // Bottom Margin
  if (theOscMessage.checkAddrPattern("/P3/AreaHeight") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int myHeight = theOscMessage.get(1).intValue();
    _populations[populationId]._area.setHeight(myHeight);
    return;
  }
  
  // Population size
  if (theOscMessage.checkAddrPattern("/P3/PopulationSize") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int populationSize = theOscMessage.get(1).intValue();
    _populations[populationId].setPopulationSize(populationSize);
    return;
  }
  
  // Frame rate
  if (theOscMessage.checkAddrPattern("/P3/FrameRate") && theOscMessage.checkTypetag("i") ) {
    int rate = theOscMessage.get(0).intValue();
    if (rate > 60) return;
    frameRate(rate);
    return;
  }
}