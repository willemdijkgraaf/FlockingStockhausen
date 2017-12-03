import oscP5.*;
OscP5 _oscP5;

int _clock;
int _groupMembershipUpdateRate;
Margins _margins;
Vehicles _vehicles;

void setup() {

  size(1280, 720);
  frameRate(40);

  _groupMembershipUpdateRate = 10;
  int initialPopulationSize = 0;
  float swarmDistance = 50;
  float desiredDistance = 30;


  float marginTop = 2 * 4;
  float marginBottom = height - 2 * 4;
  float marginLeft = 2* 4;
  float marginRight = width - 2 * 4;
  _margins = new Margins(marginTop, marginRight, marginBottom, marginLeft);
  _vehicles = new Vehicles(initialPopulationSize, swarmDistance, desiredDistance, _margins);

  _oscP5 = new OscP5(this, 10001);
}

void draw() {
  if (mousePressed) {
    _margins.setTop(_margins.getTop() + 10);
    _margins.setBottom(_margins.getBottom() - 10);
    _margins.setLeft(_margins.getLeft() + 10);
    _margins.setRight(_margins.getRight() - 10);
  }

  _clock++;
  if (_clock % _groupMembershipUpdateRate == 1) {
    // reset group membership, groupsizes & apply behaviors
    _vehicles.updateGroupMembership();
  }

  background(60);
  _margins.draw();
  _vehicles.draw();
}

void oscEvent(OscMessage theOscMessage) {
  // Left Margin
  if (theOscMessage.checkAddrPattern("/P3/LeftMargin") && theOscMessage.checkTypetag("i") ) {
    int leftMargin = theOscMessage.get(0).intValue();
    _margins.setLeft(leftMargin);
    return;
  }
  
  // Right Margin
  if (theOscMessage.checkAddrPattern("/P3/RightMargin") && theOscMessage.checkTypetag("i") ) {
    int rightMargin = theOscMessage.get(0).intValue();
    _margins.setRight(rightMargin);
    return;
  }
  
  // Top Margin
  if (theOscMessage.checkAddrPattern("/P3/TopMargin") && theOscMessage.checkTypetag("i") ) {
    int topMargin = theOscMessage.get(0).intValue();
    _margins.setTop(topMargin);
    return;
  }
  
  // Bottom Margin
  if (theOscMessage.checkAddrPattern("/P3/BottomMargin") && theOscMessage.checkTypetag("i") ) {
    int bottomMargin = theOscMessage.get(0).intValue();
    _margins.setBottom(bottomMargin);
    return;
  }
  
  // Population size
  if (theOscMessage.checkAddrPattern("/P3/PopulationSize") && theOscMessage.checkTypetag("i") ) {
    int populationSize = theOscMessage.get(0).intValue();
    _vehicles.setPopulationSize(populationSize);
    return;
  }
}