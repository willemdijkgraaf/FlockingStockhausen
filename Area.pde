class Area {
  private float _y, _w, _h, _x;

  Area(float x, float y, float w, float h) {
    _y = y;
    _w = w;
    _h = h;
    _x = x;
  }

  float getY() {
    return _y;
  }
  
  float getPositionTop() {return _y;}
  
  void setY(float value) {
    if (value > height) return;
    _y = value;
  }

  float getWidth() {return _w;}
  
  float getPositionRight() {
    return _x + _w;
  }
  void setWidth(float value) {
    if (value < 0) return;
    _w = value;
  }

  float getPositionBottom() {
    return _y + _h;
  }
  void setHeight(float value) {
    if (value < 0) return;
    _h = value;
  }

  float getX() {
    return _x;
  }
  
  float getPositionLeft() {
    return _x;
  }
  void setX(float value) {
    if (value < 0) return;
    _x = value;
  }
  
  void draw(){
    fill(60,0);
    stroke(255);
    rect(_x, _y, _w, _h);
  }
}