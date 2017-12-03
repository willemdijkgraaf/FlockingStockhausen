int _clock;
int _groupMembershipUpdateRate;
Margins _margins;
Vehicles _vehicles;

void setup() {

  size(1280, 720);
  frameRate(40);

  _groupMembershipUpdateRate = 10;
  int initialPopulationSize = 50;
  float swarmDistance = 50;
  float desiredDistance = 30;
  
  
  float marginTop = 2 * 4;
  float marginBottom = height - 2 * 4;
  float marginLeft = 2* 4;
  float marginRight = width - 2 * 4;
  _margins = new Margins(marginTop, marginRight, marginBottom, marginLeft);
  _vehicles = new Vehicles(initialPopulationSize, swarmDistance, desiredDistance, _margins);
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