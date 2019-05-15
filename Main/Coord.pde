public class Coord implements Comparable<Coord> {
  public int x, y;
  public Coord(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  @Override
  public boolean equals(Object o) {
    Coord c = (Coord) o;
    return (x == c.x && y == c.y);
  }
  
  public int compareTo(Coord c) {
    if (x == c.x && y == c.y)
      return 1;
    return 0;
  }
}
