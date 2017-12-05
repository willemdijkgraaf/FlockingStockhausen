class Population {
  int _id;
  Synth _synth;
  Vehicle[] _vehicles;
  int[] _groupSizes;
  int _lastGroupId;
  float _swarmDistance;
  final int _maxPopulationSize = 500;
  int _populationSize;
  float _desiredDistance;
  Area _area;
  
  Population(
    int id,
    int intitialPopulationSize, 
    float swarmDistance, 
    float desiredDistance, 
    Area area,
    Synth synth) 
  {
    _id = id;
    _populationSize = intitialPopulationSize;
    _swarmDistance = swarmDistance;
    _swarmDistance = swarmDistance;
    _desiredDistance = desiredDistance;
    _area = area;
    _vehicles = new Vehicle[_maxPopulationSize];
    _groupSizes = new int[_maxPopulationSize];
    _synth = synth;
    initPopulation(0, _populationSize);  
  }
  
  void initPopulation(int low, int amount){
    for (int i = low; i < low + amount; i++) {
      float x = random(_area.getPositionLeft(), _area.getPositionRight());
      float y = random(_area.getPositionTop(), _area.getPositionBottom());
      float maxSpeed = random(2, 4);
      float maxForce = random(0.75, 1.25);
      float mass = 1.0;
      int synthId = this._id * _maxPopulationSize + i;
      _vehicles[i] = new Vehicle(i, synthId, x, y, maxSpeed, maxForce, mass, _desiredDistance, _swarmDistance, _area, _synth);
      
      _synth.createSynth(synthId);
      println("create start: " + synthId + " amount: " + amount);
    }
  }
  
  void setPopulationSize(int populationSize) {
    if (populationSize > _maxPopulationSize) return;
    
    if (populationSize > _populationSize) {
      int amount = populationSize - _populationSize;
      int startId = _populationSize;
      initPopulation(startId, amount);
    }
    
    if (populationSize < _populationSize) {
      int index = populationSize-1;
      if (index < 0) index = 0;
      int synthId = _vehicles[index]._synthId;
      int amount = _populationSize - populationSize;
      println("remove start: " + synthId + " amount: " + amount);
      _synth.stopRange( synthId, amount);
    }
    
    _populationSize = populationSize;
    
    
  }
  
  void resetGroupMembership (int member) {
    _vehicles[member].groupId = 0;
    _groupSizes[member] = 0;
  }

  void setGroupIds (int member, int groupId) {
    Vehicle me = _vehicles[member];
    me.groupId = groupId;
    _groupSizes[groupId]++;
    for (int i = 0; i < _populationSize; i++) {
      Vehicle other = _vehicles[i];
      if ((other != me) && (other.groupId != groupId)) {
        float d = PVector.dist(me._pos, other._pos);
        if ((d > 0) && (d < this._swarmDistance)) {
          setGroupIds(i, groupId);
        }
      }
    }
  }

  void updateGroupMembership() {
    for (int i = 0; i < _populationSize; i++) {
      resetGroupMembership(i);
    }

    // derive group membership
    _lastGroupId = 0;
    for (int me = 0; me < _populationSize; me++) {
      setGroupMembership(me);
    }
  }

  void setGroupMembership (int member) {
    if (_vehicles[member].groupId > 0) return; // is already a member of a group
    _lastGroupId++;
    setGroupIds(member, _lastGroupId);
  }

  void draw() {
    for (int i = 0; i < _populationSize; i++) {
      _vehicles[i].applyBehaviors(_vehicles, _populationSize);
      int groupSize = 0;
      if (_vehicles[i].groupId > 0) {
        groupSize = _groupSizes[_vehicles[i].groupId];
        
      }
      _vehicles[i].setGroupSize(groupSize);
      float groupIntensity = 255;
      if (groupSize > 1) {
        groupIntensity = map(((float)groupSize/_populationSize), 0, 1, 127, 255 );
      }
      _vehicles[i].display(groupSize, (int)groupIntensity);
    }
  }
}