class Point {
  private int x;
  
  private int y;
  
  private float value;
  
  public Point(int x, int y, float value) {
    this.x = x;
    this.y = y;
    this.value = value;
  }
  
  public boolean equals(Object o) {
    if (o == null) {
      return false;
    }
    
    if (! (o instanceof Point)) {
      return false;
    }
    
    Point other = (Point) o;
    
    return this.x == other.x &&
           this.y == other.y;
  }
  
  public int hashCode() {
    return (x + "," + y).hashCode();
  }
  
  public float getValue() {
    return this.value;
  }
}