import java.util.LinkedList;
import oscP5.*;
import netP5.*;

OscP5 _osc;

int _clock;
int _groupMembershipUpdateRate;
Margins _margins;
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
  
  float marginTop = 2 * 4;
  float marginBottom = (height/2) - 2 * 4;
  float marginLeft = 2* 4;
  float marginRight = (width/2) - 2 * 4;
  _margins = new Margins(marginTop, marginRight, marginBottom, marginLeft);
  _populations[0] = new Population(0, initialPopulationSize, swarmDistance, desiredDistance, _margins, synth);
 
  marginTop = (height/2) - 2 * 4;
  marginBottom = (height) - 2 * 4;
  marginLeft = (width/2) - 2* 4;
  marginRight = (width) - 2 * 4;
  _margins = new Margins(marginTop, marginRight, marginBottom, marginLeft);
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
      population._margins.draw();
      population.draw();
    }
  
}

void oscEvent(OscMessage theOscMessage) {
  // Left Margin
  if (theOscMessage.checkAddrPattern("/P3/LeftMargin") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int leftMargin = theOscMessage.get(1).intValue();
    _populations[populationId]._margins.setLeft(leftMargin);
    return;
  }
  
  // Right Margin
  if (theOscMessage.checkAddrPattern("/P3/RightMargin") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int rightMargin = theOscMessage.get(1).intValue();
    _populations[populationId]._margins.setRight(rightMargin);
    return;
  }
  
  // Top Margin
  if (theOscMessage.checkAddrPattern("/P3/TopMargin") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int topMargin = theOscMessage.get(1).intValue();
    _populations[populationId]._margins.setTop(topMargin);
    return;
  }
  
  // Bottom Margin
  if (theOscMessage.checkAddrPattern("/P3/BottomMargin") && theOscMessage.checkTypetag("i") ) {
    int populationId = theOscMessage.get(0).intValue();
    int bottomMargin = theOscMessage.get(1).intValue();
    _populations[populationId]._margins.setBottom(bottomMargin);
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