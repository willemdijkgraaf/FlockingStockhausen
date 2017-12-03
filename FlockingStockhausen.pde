import java.util.LinkedList;
Vehicle[] _vehicles;
int[] _groupSizes;
int _lastGroupId;
int _clock;
int _groupMembershipUpdateRate;

int _vehicleAmount = 200;

float _swarmDistance;
void setup(){
  
  size(1280, 720);
  frameRate(40);
  
  _vehicles = new Vehicle[_vehicleAmount];
  _groupSizes = new int[_vehicleAmount];
  
  _groupMembershipUpdateRate = 10;
  
  float desiredDistance = 30;
  _swarmDistance = 50;
    
  for (int i = 0; i< _vehicleAmount; i++){
    float x = random(width);
    float y = random(height);
    float maxSpeed = random(2,4);
    float maxForce = random(0.75,1.25);
    float mass = 1.0;
    _vehicles[i] = new Vehicle(x, y, maxSpeed, maxForce, mass, desiredDistance, _swarmDistance);
  }
}

void resetGroupMembership (int member) {
  _vehicles[member].groupId = 0;
  _groupSizes[member] = 0;
}

void setGroupIds (int member, int groupId) {
  Vehicle me = _vehicles[member];
  me.groupId = groupId;
  _groupSizes[groupId]++;
  for (int i = 0; i < _vehicles.length; i++){
    Vehicle other = _vehicles[i];
    if ((other != me) && (other.groupId != groupId)) {
      float d = PVector.dist(me.pos, other.pos);
      if ((d > 0) && (d < this._swarmDistance)) {
        setGroupIds(i, groupId);
      }
    }
  }
}

void setGroupMembership (int member) {
  if (_vehicles[member].groupId > 0) return;
  _lastGroupId++;
  setGroupIds(member, _lastGroupId);
}

void draw(){
  if (mousePressed) {return;}
 background(60);
 _clock++;
 if (_clock % _groupMembershipUpdateRate == 1) {
   // reset group membership, groupsizes & apply behaviors
   for (int i = 0; i < _vehicles.length; i++){
     resetGroupMembership(i);
   }
   
   // derive group membership
   _lastGroupId = 0;
   for (int me = 0; me < _vehicles.length; me++){
      setGroupMembership(me);
   }
 }
 
 
 for (int i = 0; i < _vehicles.length; i++){
   _vehicles[i].applyBehaviors(_vehicles);
   float groupSize = 0;
   if (_vehicles[i].groupId > 0) {groupSize = _groupSizes[_vehicles[i].groupId];}
   float groupIntensity = 255;
   if (groupSize > 1) {groupIntensity = map(((float)groupSize/_vehicleAmount), 0, 1, 127, 255 );}
   _vehicles[i].display((int)groupSize, (int)groupIntensity);
 }
}