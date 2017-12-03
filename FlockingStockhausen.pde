int _clock;
int _groupMembershipUpdateRate;
Vehicles _vehicles;

void setup() {

  size(1280, 720);
  frameRate(40);

  _groupMembershipUpdateRate = 10;
  int initialPopulationSize = 50;
  float swarmDistance = 50;
  float desiredDistance = 30;
  _vehicles = new Vehicles(initialPopulationSize, swarmDistance, desiredDistance);
}

void draw() {
  if (mousePressed) {
    _vehicles.setPopulationSize(_vehicles._populationSize+10);
  }
  
  _clock++;
  if (_clock % _groupMembershipUpdateRate == 1) {
    // reset group membership, groupsizes & apply behaviors
    _vehicles.updateGroupMembership();
  }

  background(60);
  _vehicles.draw();
}