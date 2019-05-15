import java.util.ArrayList;
import java.util.AbstractMap.SimpleEntry;

/**
 * Grid.java Author: Nolan Kornelsen Purpose: Implement a grid of elements (each
 * one has a corresponding unique coordinate pair)
 */

public class Node<T> {
  public T data;
  public int x, y;
  Node<T> left, right, up, down;

  public Node(T data, int x, int y) {
    this.x = x;
    this.y = y;
    this.data = data;
  }

  @Override
    public String toString() {
    return "(" + x + ", " + y + "): " + data;
  }
}

public class Grid<T> {


  int xMax = 0, yMax = 0, xMin = 0, yMin = 0;
  public ArrayList<Edge> edges;

  public ArrayList<Node<T>> nodeList;
  private Node<T> origin;

  public Grid(T data) {
    this.origin = new Node<T>(data, 0, 0);
    nodeList = new ArrayList<Node<T>>();
    nodeList.add(origin);
  }

  public Grid() {
    this.origin = new Node<T>(null, 0, 0);
    nodeList = new ArrayList();
  }


  // nodes are always accessed by moving along the x-axis and then the y-axis
  // starting at the origin. The path cannot go backwards
  public T getCoordinate(int x, int y) {
    Node<T> cur = origin;
    boolean left = false;
    boolean down = false;
    if (x < 0) {
      left = true;
    }
    if (y < 0) {
      down = true;
    }

    for (int i = 0; i < Math.abs(x); i++) {
      if (left) {
        if (cur.left == null) {
          return null;
        }
        cur = cur.left;
      } else {
        if (cur.right == null) {
          return null;
        }
        cur = cur.right;
      }
    }

    for (int i = 0; i < Math.abs(y); i++) {
      if (down) {
        if (cur.down == null) {
          return null;
        }
        cur = cur.down;
      } else {
        if (cur.up == null) {
          return null;
        }
        cur = cur.up;
      }
    }

    return cur.data;
  }

  public void setCoordinate(int x, int y, T data) {
    Node<T> cur = origin;
    boolean left = false;
    boolean down = false;
    if (x < 0) {
      left = true;
    }
    if (y < 0) {
      down = true;
    }

    for (int i = 0; i < Math.abs(x); i++) {
      if (left) {
        if (cur.left == null) {
          cur.left = new Node<T>(null, i-1, 0);
        }
        cur = cur.left;
      } else {
        if (cur.right == null) {
          cur.right = new Node<T>(null, i+1, 0);
        }
        cur = cur.right;
      }
    }

    for (int i = 0; i < Math.abs(y); i++) {
      if (down) {
        if (cur.down == null) {
          cur.down = new Node<T>(null, x, i-1);
        }
        cur = cur.down;
      } else {
        if (cur.up == null) {
          cur.up = new Node<T>(null, x, i+1);
        }
        cur = cur.up;
      }
    }
    if (cur.x > xMax)
      xMax = cur.x;
    if (cur.x < xMin)
      xMin = cur.x;
    if (cur.y > yMax)
      yMax = cur.y;
    if (cur.y < yMin)
      yMin = cur.y;
    cur.data = data;
    nodeList.add(cur);
  }

  private boolean addToIntersectionList(ArrayList<SimpleEntry<Edge, Edge>> intersectionList, Edge e1, Edge e2) {
    boolean inList = false;
    for (SimpleEntry<Edge, Edge> entry : intersectionList) {
      if ((entry.getKey() == e1 || entry.getValue() == e2) || (entry.getKey() == e2 && entry.getValue() == e1)) {
        inList = true;
      }
    }
    if (!inList) {
      intersectionList.add(new SimpleEntry<Edge, Edge>(e1, e2));
    }
    return inList;
  }

  public int numIntersections(int[][] adjMat, Vertex[] vertexList) {
    int intersections = 0;
    HashMap<T, Node> vertexFinder = new HashMap();
    ArrayList<SimpleEntry<Edge, Edge>> intersectionList = new ArrayList();
    for (Node<T> n : nodeList) {
      vertexFinder.put(n.data, n);
    }
    // System.out.println("Intersections: ");
    for (Edge e1 : edges) {
      for (Edge e2 : edges) {
        if (e1.equals(e2)) {
          continue;
        }

        // print(vertexList[e1.orig] + vertexList[e1.dest].toString() + "-" + vertexList[e2.orig].toString() + vertexList[e2.dest] + ": ");
        float Ax1 = vertexFinder.get(vertexList[e1.orig]).x;
        float Ay1 = vertexFinder.get(vertexList[e1.orig]).y;
        float Ax2 = vertexFinder.get(vertexList[e1.dest]).x;
        float Ay2 = vertexFinder.get(vertexList[e1.dest]).y;
        float Bx1 = vertexFinder.get(vertexList[e2.orig]).x;
        float By1 = vertexFinder.get(vertexList[e2.orig]).y;
        float Bx2 = vertexFinder.get(vertexList[e2.dest]).x;
        float By2 = vertexFinder.get(vertexList[e2.dest]).y;
        // print("(" + Ax1 + ", " + Ay1 + ")(" + Ax2 + ", " + Ay2 + ") and (" + Bx1 + ", " + By1 + ")(" + Bx2 + ", " + By2 + "): ");

        // if both lines are vertical
        if (Ax1 == Ax2 && Bx1 == Bx2) {
          // if they are on the same y axis
          if (Ax1 == Bx1) {
            // if they overlap on the y axis
            if (max(Ay2, Ay1) > min(By1, By2) && max(By1, By2) > min(Ay1, Ay2)) {
              /*
              boolean inList = false;
              for (SimpleEntry<Edge, Edge> entry : intersectionList) {
                if ((entry.getKey() == e1 || entry.getValue() == e2) || (entry.getKey() == e2 && entry.getValue() == e1)) {
                  inList = true;
                }
              }
              if (!inList) {
                intersections++;
                System.out.println(vertexList[e1.orig].toString() + vertexList[e1.dest] + "-" + vertexList[e2.orig].toString() + vertexList[e2.dest] + "(OVERLAP), INTERSECTIONS" + intersections + " ");
              }
              */
              if (!addToIntersectionList(intersectionList, e1, e2)) {
                intersections++;
              }
            } else {

              // println("Broke 1");
            }
          } else {

            // println("Broke 2");
          }
          continue;
        }

        // if e1 is vertical but not e2
        else if (Ax1 == Ax2) {
          float h = By1 + ((By2-By1)/(Bx2-Bx1)) * (Ax1 + Bx1);
          if (h > min(Ay1, Ay2) && h < max(Ay1, Ay2)) {
            if (!addToIntersectionList(intersectionList, e1, e2)) {
                intersections++;
            }
          } else {

            //  println("Broke 3");
          }

          continue;
        }

        // e2 is vertical
        else if (Bx1 == Bx2) {
          float m1 = (Ay2 - Ay1)/(Ax2 - Ax1);
          float b1 = Ay1 - (Ax1 * (Ay2 - Ay1)/(Ax2 - Ax1));
          float h = (m1 * Bx1) + b1;
          if (h > (float) min(By1, By2) && h < (float) max(By1, By2)) {
            if (!addToIntersectionList(intersectionList, e1, e2)) {
                intersections++;
            }
          }
          continue;
        } else {
          float m1 = (Ay2 - Ay1)/(Ax2 - Ax1);
          float m2 = (By2 - By1)/(Bx2 - Bx1);
          float b1 = Ay1 - (m1 * Ax1);
          float b2 = By1 - (m2 * Bx1);

          if (m1 == m2 && b1 != b2) {
            // parallel lines
            continue;
          } else if (m1 == m2 && b1 == b2) {
            // same lines
            if (min(Ax1, Ax2) < max(Bx1, Bx2) && max(Ax1, Ax2) > min(Bx1, Bx2)) {
              if (!addToIntersectionList(intersectionList, e1, e2)) {
                intersections++;
            }
              continue;
            }
          }

          double x = (b2 - b1)/(m1 - m2);
          if (x > min(Ax1, Ax2) && x < max(Ax1, Ax2) && x > min(Bx1, Bx2) && x < max(Bx1, Bx2)) {
            if (!addToIntersectionList(intersectionList, e1, e2)) {
                intersections++;
                // System.out.println(vertexList[e1.orig].toString() + vertexList[e1.dest] + "-" + vertexList[e2.orig].toString() + vertexList[e2.dest] + "(CROSS), INTERSECTIONS: " + intersections + " ");
            }
            
          }

          // println();
        }
      }
    }
    return intersections;
  }
}
