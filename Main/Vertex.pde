final int CIRCLESIZE = 40;
int WIDTH, CENTERX, CENTERY;

class Vertex {
  public char label;
  public int index;
  public boolean wasVisited;
  public boolean selected;
  int x, y;

  public Vertex(char lab, int index) {
    label = lab;
    wasVisited = false;
    this.index = index;
  }
  
  public void setCoords(int nVerts, int vertNum, boolean def, float offset) {
    x = (int) (WIDTH*cos(offset+vertNum*(2*PI/nVerts))+CENTERX);
    y = (int) (WIDTH*sin(offset+vertNum*(2*PI/nVerts))+CENTERY);
  }
  
  public void setCoords(int xNew, int yNew) {
    this.x = xNew;
    this.y = yNew;
  }
  
  public void drawVert(int density, int maxDensity) {
    if (selected) {
      strokeWeight(5);
    } else {
      strokeWeight(2);
    }
    if (maxDensity == 0) {
      maxDensity = 1;
    }
    fill(255 - (density * 255 / maxDensity), (density * 255 / maxDensity), 255);
    ellipse(this.x, this.y, CIRCLESIZE, CIRCLESIZE);
    fill(255);
  }
  
  public int distanceTo(Vertex v) {
    return (int) Math.sqrt(Math.pow(x - v.x, 2) + Math.pow(y - v.y, 2));
  }

  @Override
    public String toString() {
    return Character.toString(label);
  }
}
