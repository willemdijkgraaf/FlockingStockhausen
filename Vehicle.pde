class Vehicle {
  float mass;
  PVector pos;
  PVector vel;
  PVector acc;
  float size;
  float maxSpeed;
  float maxForce;
  float desiredDistance;
  float swarmDistance;
  
  int groupId;
  
  float marginTop, marginRight, marginBottom, marginLeft;
  
  Vehicle(float x, float y, float ms, float mf, float mss, float desDistance, float swmDistance) {
    pos = new PVector(x, y);
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    this.maxSpeed = ms;
    this.maxForce = mf;
    this.mass = mss;
    this.size = this.mass * 4;
    this.desiredDistance = desDistance;
    this.swarmDistance = swmDistance;
    
    marginTop = 2 * size;
    marginBottom = height - 2 * size;
    marginLeft = 2* size;
    marginRight = width - 2 * size;
  }
  
  void applyBehaviors(Vehicle[] vehicles) {
    PVector separateForce = separate(vehicles);
    PVector alignForce = align(vehicles);
    PVector cohesionForce = cohesion(vehicles);

    //separateForce.mult(1);
    //alignForce.mult(1);
    //cohesionForce.mult(1);

    this.applyForce(separateForce);
    this.applyForce(alignForce);
    this.applyForce(cohesionForce);
  }
  
  void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(mass);
    acc.add(f);
  }
  
  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.set(0, 0);
  }

  void borders() {
    // jump from left to right or from top to bottom (and vice versa)
    //if (this.pos.x < -this.r) this.pos.x = width+this.r;
    //if (this.pos.y < -this.r) this.pos.y = height+this.r;
    //if (this.pos.x > width+this.r) this.pos.x = -this.r;
    //if (this.pos.y > height+this.r) this.pos.y = -this.r;
    
    // bounce of the borders
    if (this.pos.x < marginLeft) {
      this.vel.x = this.vel.x * -1.0;
      this.pos.x = this.pos.x + size;
    }
    if (this.pos.y < marginTop) {
      this.vel.y = this.vel.y * -1.0;
      this.pos.y = this.pos.y + size;
    }
    if (this.pos.x > marginRight) {
      this.vel.x = this.vel.x * -1.0;
      this.pos.x = this.pos.x - size;
    }
    if (this.pos.y > marginBottom) {
      this.vel.y = this.vel.x * -1.0;
      this.pos.y = this.pos.y - size;
    }
  }



  PVector separate(Vehicle[] vehicles) {
    PVector sum = new PVector(0, 0);
    int count = 0;

    for (int i = 0; i < vehicles.length; i++) {
      float d = PVector.dist(this.pos, vehicles[i].pos);
      if ((d > 0) && (d < this.desiredDistance)) {
        PVector diff = PVector.sub(this.pos, vehicles[i].pos);
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxSpeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxForce);
      return steer;
    } else {
      return  new PVector(0, 0);
    }
  }

  PVector align(Vehicle[] vehicles) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < vehicles.length; i++) {
      float d = PVector.dist(this.pos, vehicles[i].pos);
      if ((d > 0) && (d < this.swarmDistance)) {
        sum.add(vehicles[i].vel);
        count++;
      }
    }

    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(maxSpeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  // seek in a swarm
  PVector cohesion(Vehicle[] vehicles) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (int i = 0; i < vehicles.length; i++) {
      float d = PVector.dist(pos, vehicles[i].pos);
      if ((d > 0) && (d < this.desiredDistance)) {
        sum.add(vehicles[i].pos);
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
    PVector desired = PVector.sub(target, pos);

    // the arrive behavior
    float d = desired.mag();
    if (d < 100) {
      float m = map(d, 0, 100, 0, maxSpeed);
      desired.setMag(m);
    } else {
      desired.setMag(maxSpeed);
    }

    PVector steering = PVector.sub(desired, vel);
    steering.limit(maxForce);
    return steering;
  }
  
  public void display(int groupCount, int groupIntensity) {
    update();
    borders();
    drawMe(groupCount, groupIntensity);
  }

  void drawMe(int groupCount, int intensity) {
    float theta = vel.heading() + PI / 2;
    color myColor = color(intensity,0,0);
    if (groupCount > 1) {myColor = color (0,intensity,0);} // member of group
    if (groupCount > 7) {myColor = color(0,0,intensity);} // member of swarm
    fill(myColor);
    stroke(myColor);
    strokeWeight(1);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(theta);
    beginShape();
    vertex(0, -size*2);
    vertex(-size, size * 2);
    vertex(size, size*2);
    endShape(CLOSE);
    popMatrix();
  }
}