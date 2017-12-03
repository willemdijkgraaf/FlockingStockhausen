class Margins {
  private float _top, _right, _bottom, _left;

  Margins(float top, float right, float bottom, float left) {
    _top = top;
    _right = right;
    _bottom = bottom;
    _left = left;
  }

  float getTop() {
    return _top;
  }
  void setTop(float value) {
    if (value > _bottom) return;
    _top = value;
  }

  float getRight() {
    return _right;
  }
  void setRight(float value) {
    if (value < _left) return;
    _right = value;
  }

  float getBottom() {
    return _bottom;
  }
  void setBottom(float value) {
    if (value < _top) return;
    _bottom = value;
  }

  float getLeft() {
    return _left;
  }
  void setLeft(float value) {
    if (value > _right) return;
    _left = value;
  }
  
  void draw(){
    fill(60);
    stroke(255);
    rect(_left, _top, _right - _left, _bottom - _top);
  }
}