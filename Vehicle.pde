class Vehicle {
  Synth _synth;
  int _id;
  float _mass;
  PVector _pos;
  PVector _vel;
  PVector _acc;
  float _size;
  float _maxSpeed;
  float _maxForce;
  float _desiredDistance;
  float _swarmDistance;
  Margins _margins;
  
  int groupId;
  int _groupType;
  int _previousGroupType;
  
  Vehicle(
    int id,
    float x, 
    float y, 
    float ms, 
    float mf, 
    float mss, 
    float desDistance, 
    float swmDistance,
    Margins margins,
    Synth synth
  ) {
    _id = id;
    _pos = new PVector(x, y);
    _vel = new PVector(0, 0);
    _acc = new PVector(0, 0);
    this._maxSpeed = ms;
    this._maxForce = mf;
    this._mass = mss;
    this._size = this._mass * 4;
    this._desiredDistance = desDistance;
    this._swarmDistance = swmDistance;
    this._margins = margins;
    this._synth = synth;
  }
  
  void applyBehaviors(Vehicle[] vehicles, int populationSize) {
    PVector separateForce = separate(vehicles, populationSize);
    PVector alignForce = align(vehicles, populationSize);
    PVector cohesionForce = cohesion(vehicles, populationSize);

    //separateForce.mult(1);
    //alignForce.mult(1);
    //cohesionForce.mult(1);

    this.applyForce(separateForce);
    this.applyForce(alignForce);
    this.applyForce(cohesionForce);
  }
  
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(_mass);
    _acc.add(f);
  }
  
  void update() {
    _vel.add(_acc);
    _vel.limit(_maxSpeed);
    _pos.add(_vel);
    _acc.set(0, 0);
  }

  void borders() {
    
    // bounce of the borders
    if (this._pos.x < _margins.getLeft()) {
      this._vel.x = this._vel.x * -1.0;
      this._pos.x = this._pos.x + _size;
    }
    if (this._pos.y < _margins.getTop()) {
      this._vel.y = this._vel.y * -1.0;
      this._pos.y = this._pos.y + _size;
    }
    if (this._pos.x > _margins.getRight()) {
      this._vel.x = this._vel.x * -1.0;
      this._pos.x = this._pos.x - _size;
    }
    if (this._pos.y > _margins.getBottom()) {
      this._vel.y = this._vel.x * -1.0;
      this._pos.y = this._pos.y - _size;
    }
  }



  PVector separate(Vehicle[] vehicles, int populationSize) {
    PVector sum = new PVector(0, 0);
    int count = 0;

    for (int i = 0; i < populationSize; i++) {
      float d = PVector.dist(this._pos, vehicles[i]._pos);
      if ((d > 0) && (d < this._desiredDistance)) {
        PVector diff = PVector.sub(this._pos, vehicles[i]._pos);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(_maxSpeed);
      PVector steer = PVector.sub(sum, _vel);
      steer.limit(_maxForce);
      return steer;
    } else {
      return  new PVector(0, 0);
    }
  }

  PVector align(Vehicle[] vehicles, int populationSize) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < populationSize; i++) {
      float d = PVector.dist(this._pos, vehicles[i]._pos);
      if ((d > 0) && (d < this._swarmDistance)) {
        sum.add(vehicles[i]._vel);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(_maxSpeed);
      PVector steer = PVector.sub(sum, _vel);
      steer.limit(_maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // seek in a swarm
  PVector cohesion(Vehicle[] vehicles, int populationSize) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < populationSize; i++) {
      float d = PVector.dist(_pos, vehicles[i]._pos);
      if ((d > 0) && (d < this._desiredDistance)) {
        sum.add(vehicles[i]._pos);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }
  
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, _pos);

    // the arrive behavior
    float d = desired.mag();
    if (d < 100) {
      float m = map(d, 0, 100, 0, _maxSpeed);
      desired.setMag(m);
    } else {
      desired.setMag(_maxSpeed);
    }

    PVector steering = PVector.sub(desired, _vel);
    steering.limit(_maxForce);
    return steering;
  }
  
  void setGroupSize(int size) {
    _previousGroupType = _groupType;
    if (size > 7) {_groupType = 2;} // mass
    else if (size > 1) {_groupType = 1;} // group
    else {_groupType = 0;} // point
    
    if (_groupType != _previousGroupType) {
      _synth.changeSynth(_id, _groupType);
    }
  }
  public void display(int groupCount, int groupIntensity) {
    update();
    borders();
    drawMe(groupCount, groupIntensity);
    playMe();
  }
  void playMe() {
    int freq = (int)map(height - _pos.y, 0, height, 50, 4000);
    float amp = map(_pos.x, 0, width, 0, 1);
    _synth.adjustSynth(_id,freq,amp);
  }
  
  void drawMe(int groupCount, int intensity) {
    float theta = _vel.heading() + PI / 2;
    color myColor = color(intensity,0,0);
    if (groupCount > 1) {myColor = color (0,intensity,0);} // member of group
    if (groupCount > 7) {myColor = color(0,0,intensity);} // member of swarm
    fill(myColor);
    stroke(myColor);
    strokeWeight(1);
    pushMatrix();
    translate(_pos.x, _pos.y);
    rotate(theta);
    beginShape();
    vertex(0, -_size*2);
    vertex(-_size, _size * 2);
    vertex(_size, _size*2);
    endShape(CLOSE);
    popMatrix();
  }
}