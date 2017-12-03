class Margins {
  private float _top, _right, _bottom, _left;
  
  Margins(float top, float right, float bottom, float left) {
    _top = top;
    _right = right;
    _bottom = bottom;
    _left = left;
  }
  
  float getTop() {return _top;}
  void setTop(float value) {_top = value;}
  
  float getRight() {return _right;}
  void setRight(float value) {_right = value;}

  float getBottom() {return _bottom;}
  void setBottom(float value) {_bottom = value;}
  
  float getLeft() {return _left;}
  void setLeft(float value) {_left = value;}
}