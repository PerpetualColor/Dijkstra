/**
 * Graph.java
 * Author: Nolan Kornelsen
 * Purpose: Implement a graph of vertices
 */
import java.util.Stack;
import java.util.ArrayList;
import java.util.Random;

class Graph {
  protected final int MAX_VERTS = 50;
  public Vertex[] vertexList;
  protected int[][] adjMat;
  public int nVerts;
  public boolean pathFound;
  public ArrayList<Integer> foundPath;
  boolean selectingVertex;
  boolean chooseV1;
  boolean selectingEdge;
  boolean dynWeight;
  boolean pathing;
  int pathStart, pathEnd;
  int edgeStart, edgeEnd;
  int edgeFactor;
  int prevEdgeLen;

  // allocate memory
  public Graph() {
    vertexList = new Vertex[MAX_VERTS];
    adjMat = new int[MAX_VERTS][MAX_VERTS];
    nVerts = 0;
  }

  // insert a vertex
  public void addVertex(char lab) {
    vertexList[nVerts++] = new Vertex(lab, nVerts - 1);
  }

  // add an edge
  public void addEdge(int start, int end) {
    adjMat[start][end] = 1;
    adjMat[end][start] = 1;
  }

  // print information about vertex at index v
  public void displayVertex(int v) {
    System.out.print("Vertex " + v + " is connected to:");
    for (int i = 0; i < MAX_VERTS; i++) {
      if (adjMat[v][i] != 0) {
        System.out.print(" " + vertexList[i].label);
      }
    }
    System.out.println();
  }

  public int[] getConnectedVertices(int v) {
    ArrayList<Integer> verts = new ArrayList();
    for (int i = 0; i < nVerts; i++) {
      if (adjMat[v][i] != 0) {
        verts.add(i);
      }
    }
    int[] intArray = new int[verts.size()];
    for (int i = 0; i < intArray.length; i++) {
      intArray[i] = verts.get(i);
    }
    return intArray;
  }

  float getXCoord(int v) {
    return WIDTH*cos(v*(2*PI/g.nVerts))+CENTERX;
  }

  float getYCoord(int v) {
    return WIDTH*sin(v*(2*PI/g.nVerts))+CENTERY;
  }

  public void calcDensity() {
    density = new int[nVerts];
    boolean[] visited = new boolean[nVerts];
    for (int i = 0; i < nVerts; i++) {
      for (int j = 0; j < nVerts; j++) {
        if (adjMat[i][j] != 0) {
          density[i]++;
        }
      }
    }
  }

  private void drawLines() {
    for (int v = 0; v < nVerts; v++) {
      int[] verts = g.getConnectedVertices(v);
      for (int i = 0; i < verts.length; i++) {
        line(vertexList[v].x, vertexList[v].y, vertexList[verts[i]].x, vertexList[verts[i]].y);
      }
    }
    if (pathFound) {
      for (int i = 0; i < foundPath.size() - 1; i++) {
        stroke(0, 255, 0);
        strokeWeight(4);
        line(vertexList[foundPath.get(i)].x, vertexList[foundPath.get(i)].y, vertexList[foundPath.get(i+1)].x, vertexList[foundPath.get(i+1)].y);
        stroke(0);
        strokeWeight(2);
      }
    }
    for (int v = 0; v < nVerts; v++) {
      int[] verts = g.getConnectedVertices(v);
      for (int i = 0; i < verts.length; i++) {
        String w = Integer.toString(adjMat[v][verts[i]]);
        float textWidth = textWidth(w) * 1.5 / 2;
        float textHeight = (textAscent() + textDescent()) / 2;
        noStroke();
        fill(255);
        rect(((vertexList[verts[i]].x + vertexList[v].x) / 2) - textWidth, ((vertexList[verts[i]].y + vertexList[v].y) / 2) - textHeight, textWidth * 2, textHeight * 2);
        stroke(0);
        fill(0);
        textAlign(CENTER, CENTER);
        text(w, ((vertexList[verts[i]].x + vertexList[v].x) / 2), ((vertexList[verts[i]].y + vertexList[v].y) / 2));
      }
    }
  }

  int[] density;
  int maxDensity;

  public void arrangeCircle(boolean init) {
    fill(255);
    strokeWeight(2);
    if (init) {
      calcDensity();
    }
    for (int i = 0; i < nVerts; i++) {
      vertexList[i].setCoords(nVerts, i, true, SPINOFFSET);
    }
  }

  public void drawPoints() {
    int maxIndex = 0;
    for (int i = 0; i < density.length; i++) {
      if (density[i] > density[maxIndex]) {
        maxIndex = i;
      }
    }
    maxDensity = density[maxIndex];

    drawLines();

    for (int i = 0; i < g.nVerts; i++) {
      vertexList[i].drawVert(density[i], maxDensity);
    }
    fill(0);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < g.nVerts; i++) {
      text(Character.toString(g.vertexList[i].label), vertexList[i].x, vertexList[i].y);
    }
  }

  ArrayList<Coord> takenCoords;

  private Grid<Vertex> init(int gSize) {
    Grid<Vertex> g = new Grid();
    Random r = new Random();
    takenCoords = new ArrayList();
    for (int i = 0; i < nVerts; i++) {
      int x = r.nextInt(gSize);
      int y = r.nextInt(gSize);
      while (takenCoords.contains(new Coord(x, y))) {
        x = r.nextInt(gSize);
        y = r.nextInt(gSize);
      }
      takenCoords.add(new Coord(x, y));
      g.setCoordinate(x, y, vertexList[i]);
    }
    return g;
  }

  private int cost(Grid g) {
    return g.numIntersections(adjMat, vertexList);
  }

  // return a new grid with two locations swapped
  private Grid<Vertex> step(final Grid<Vertex> init, int gSize) {
    Random rand = new Random();
    // select first location
    int a = rand.nextInt(init.nodeList.size());
    // select second location
    int Bx = rand.nextInt(gSize);
    int By = rand.nextInt(gSize);
    while (init.nodeList.get(a).x == Bx && init.nodeList.get(a).y == By) {
      Bx = rand.nextInt(gSize);
      By = rand.nextInt(gSize);
    }
    // copy data into new grid
    Grid<Vertex> newG = new Grid();
    newG.edges = init.edges;
    for (int i = 0; i < init.nodeList.size(); i++) {
      Node<Vertex> node = init.nodeList.get(i);
      if (i == a) {
        newG.setCoordinate(Bx, By, init.nodeList.get(a).data);
        if (init.getCoordinate(Bx, By) != null) {
          newG.setCoordinate(init.nodeList.get(a).x, init.nodeList.get(a).y, init.getCoordinate(Bx, By));
        }
      } else if (!(node.x == Bx && node.y == By)) {
        newG.setCoordinate(node.x, node.y, node.data);
      }
    }
    return newG;
  }

  public double acceptProb(double temp, double cost, double cPrime) {
    double deltaCost = cPrime - cost;
    if (deltaCost <= 0)
      return 1;
    else
      return Math.exp((-deltaCost / temp));
  }

  public void arrangeAnnealing(int gSize) {
    Grid<Vertex> S = init(gSize), Sprime;
    S.edges = new ArrayList();
    int intersections = 0;
    for (int i = 0; i < adjMat.length; i++) {
      for (int j = 0; j < i; j++) {
        if (adjMat[i][j] != 0) {
          S.edges.add(new Edge(i, j, 0));
        }
      }
    }
    int cost = cost(S);
    double temp = 1000;
    int steps = 0;
    while (cost > 0 && steps < 5000) {
      Sprime = step(S, gSize);
      int Cprime = cost(Sprime);
      double ap = acceptProb(temp, cost, Cprime);
      if (Math.random() < ap) {
        S = Sprime;
        cost = Cprime;
        temp = Math.max(temp - 1, 1);
      }
      steps++;
    }

    float xWidth = S.xMax - S.xMin;
    float yWidth = S.yMax - S.yMin;
    float xScale = (width * 2/5);
    float yScale = (height * 2/5);

    for (int i = 0; i < S.nodeList.size(); i++) {
      S.nodeList.get(i).data.x = (int) (((S.nodeList.get(i).x / xWidth) * xScale) + (width / 2) - (xScale / 2));
      S.nodeList.get(i).data.y = (int) (((S.nodeList.get(i).y / yWidth) * yScale) + (height / 2) - (yScale / 2));
    }
  }
}
