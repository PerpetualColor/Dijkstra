
/**
 * WGraph.java
 * Author: Nolan Kornelsen
 * Purpose: Weighted graph implementation.
 */

import java.util.ArrayList;
import java.util.Comparator;
import java.util.TreeMap;
import java.util.PriorityQueue;
import java.util.Stack;
import java.util.HashMap;
import java.util.Map;

class Edge implements Comparable<Edge> {
  public int orig, dest, weight;

  public Edge(int orig, int dest, int weight) {
    this.orig = orig;
    this.dest = dest;
    this.weight = weight;
  }

  @Override
    public int compareTo(Edge arg) {
    return this.weight - arg.weight;
  }

  @Override
    public boolean equals(Object o) {
    Edge e = (Edge) o;
    return ((orig == e.orig && dest == e.dest) || (orig == e.dest && dest == e.orig));
  }

  @Override
    public String toString() {
    return "(" + orig + "," + dest + "):" + weight;
  }
}

public class WGraph extends Graph {

  // construct
  public WGraph() {
    super();
  }

  // add an edge to the graph
  public void addEdge(int orig, int dest, int weight) {
    adjMat[orig][dest] = weight;
    adjMat[dest][orig] = weight;
  }

  // Djikstra implementation
  private class DistPar {
    public int distance, parentVert;

    public DistPar(int pv, int d) {
      parentVert = pv;
      distance = d;
    }

    @Override
      public String toString() {
      return Character.toString(vertexList[parentVert].label) + "(" + distance + ")";
    }
  }

  // find the path using Djikstra
  public void path(int orig, int dest) {
    pathing = true;
    for (int i = 0; i < nVerts; i++) {
      vertexList[i].wasVisited = false;
    }
    DistPar[] sPath = new DistPar[nVerts];
    sPath[orig] = new DistPar(orig, 0);
    int currentVert = orig;
    // run until the destination is reached
    while (currentVert != dest) {
      vertexList[currentVert].wasVisited = true;
      adjustSPath(sPath, currentVert, sPath[currentVert].distance);

      currentVert = getMin(sPath, currentVert);
    }
    // print the path
    String outputPath = vertexList[currentVert].toString() + ", Cost: " + sPath[currentVert].distance;
    foundPath = new ArrayList();
    foundPath.add(currentVert);
    pathFound = true;
    while (currentVert != orig) {
      currentVert = sPath[currentVert].parentVert;
      outputPath = vertexList[currentVert] + outputPath;
      foundPath.add(currentVert);
    }
    // System.out.println("Path: " + outputPath);
  }

  //
  private void adjustSPath(DistPar[] sPath, int vert, int dist) {
    for (int i = 0; i < nVerts; i++) {
      if ((sPath[i] == null && adjMat[vert][i] != 0)
        || (sPath[i] != null && adjMat[vert][i] != 0 && dist + adjMat[vert][i] < sPath[i].distance)) {
        sPath[i] = new DistPar(vert, dist + adjMat[vert][i]);
      }
    }
  }

  private int getMin(DistPar[] sPath, int orig) {
    int curDist = 0;
    int ret = 0;
    for (int i = 0; i < sPath.length; i++) {
      if (i != orig && !vertexList[i].wasVisited && sPath[i] != null) {
        curDist = sPath[i].distance;
        ret = i;
        break;
      }
    }
    for (int i = 0; i < sPath.length; i++) {
      if (sPath[i] != null && sPath[i].distance < curDist && !vertexList[i].wasVisited) {
        ret = i;
        curDist = sPath[i].distance;
      }
    }
    return ret;
  }

  public int selectVert(int current) {
    if (current != -1) 
      vertexList[current].selected = false;
    for (int i = 0; i < nVerts; i++) {
      if (i != current && Math.sqrt(Math.pow(mouseX - vertexList[i].x, 2) + Math.pow(mouseY - vertexList[i].y, 2)) < CIRCLESIZE/2) {
        if (!selectingVertex && !selectingEdge) {
          vertexList[i].selected = true;
          return i;
        } else if (!selectingEdge) {
          if (chooseV1) {
            pathStart = i;
            chooseV1 = false;
            return i;
          } else {
            pathEnd = i;
            // println("Selected " + i);
            path(pathStart, pathEnd);
            chooseV1 = false;
            selectingVertex = false;
            return i;
          }
        } else {
          if (chooseV1) {
            edgeStart = i;
            chooseV1 = false;
            return i;
          } else {
            edgeEnd = i;
            prevEdgeLen = vertexList[edgeStart].distanceTo(vertexList[edgeEnd]);
            adjMat[edgeStart][edgeEnd] = vertexList[edgeStart].distanceTo(vertexList[edgeEnd]) * edgeFactor / 100;
            adjMat[edgeEnd][edgeStart] = adjMat[edgeStart][edgeEnd];
            chooseV1 = false;
            selectingEdge = false;
            calcDensity();
            if (pathing) {
              g.path(pathStart, pathEnd);
            }
            return i;
          }
        }
      }
    }
    return -1;
  }

  private int getMax(int[] verts, boolean[] visited) {
    int biggest = 0;
    boolean found = false;
    for (int i = 1; i < verts.length; i++) {
      if (verts[i] > verts[biggest] && visited[i] == false) {
        found = true;
        biggest = i;
      }
    }
    if (!found) {
      return -1;
    }
    return biggest;
  }

  private ArrayList<Edge> getExtEdges(int vert1, int vert2) {
    ArrayList<Integer> unattached = new ArrayList();
    ArrayList<Integer> attached = new ArrayList();
    ArrayList<Edge> vert1Edges = new ArrayList();
    ArrayList<Edge> vert2Edges = new ArrayList();

    for (int i = 0; i < nVerts; i++) {
      if (adjMat[i][vert1] == 0) {
        unattached.add(i);
      } else {
        attached.add(i);
      }
    }
    if (attached.contains(vert2) || vert2 == vert1) {
      return null;
    }
    for (int i = 0; i < attached.size(); i++) {
      for (int j = i + 1; j < attached.size(); j++) {
        if (adjMat[attached.get(i)][attached.get(j)] != 0) {
          vert1Edges.add(new Edge(attached.get(i), attached.get(j), 1));
        }
      }
    }
    attached = new ArrayList();
    for (int i = 0; i < nVerts; i++) {
      if (adjMat[i][vert2] != 0) {
        attached.add(i);
      }
    }
    for (int i = 0; i < attached.size(); i++) {
      for (int j = i + 1; j < attached.size(); j++) {
        if (adjMat[attached.get(i)][attached.get(j)] != 0) {
          vert2Edges.add(new Edge(attached.get(i), attached.get(j), 1));
        }
      }
    }
    vert1Edges.retainAll(vert2Edges);

    return vert1Edges;
  }

  private int x, y, xMax, yMax, xMin, yMin;
  private int gWidth = 1;

  // squares are defined by the botton left vertex
  private boolean hasOpenSpace(int x, int y, Grid g) {
    return (g.getCoordinate(x, y) == null || g.getCoordinate(x + 1, y) == null
      || g.getCoordinate(x + 1, y + 1) == null || g.getCoordinate(x, y + 1) == null);
  }

  private void placeNextVert(Vertex v, Grid<Vertex> g) {
    Stack<Integer> openVertices = new Stack();
    if (g.getCoordinate(x, y + 1) == null) {
      openVertices.add(3);
    }

    if (g.getCoordinate(x + 1, y + 1) == null) {
      openVertices.add(2);
    }
    if (g.getCoordinate(x + 1, y) == null) {
      openVertices.add(1);
    }
    if (g.getCoordinate(x, y) == null) {
      openVertices.add(0);
    }

    boolean found = false;
    if (openVertices.isEmpty()) {
      while (!found) {
      outerSearchLoop:
        for (int i = 0; i < gWidth; i++) {
          for (int j = 0; j < gWidth; j++) {
            if (hasOpenSpace(j, i, g)) {
              x = j;
              y = i;
              found = true;
              placeNextVert(v, g);
              break outerSearchLoop;
            }
          }
        }
        if (!found)
          gWidth++;
        System.out.println(gWidth);
      }
    } else {
      switch (openVertices.pop()) {
      case 0:
        g.setCoordinate(x, y, v);
        if (x > xMax)
          xMax = x;
        if (y > yMax)
          yMax = y;
        if (x < xMin)
          xMin = x;
        if (y < yMin)
          yMin = y;
        break;
      case 1:
        g.setCoordinate(x + 1, y, v);
        if (x + 1 > xMax)
          xMax = x + 1;
        if (y > yMax)
          yMax = y;
        if (x + 1 < xMin)
          xMin = x + 1;
        if (y < yMin)
          yMin = y;
        break;
      case 2:
        g.setCoordinate(x + 1, y + 1, v);
        if (x + 1 > xMax)
          xMax = x + 1;
        if (y + 1 > yMax)
          yMax = y + 1;
        if (x + 1 < xMin)
          xMin = x + 1;
        if (y + 1 < yMin)
          yMin = y + 1;
        break;
      case 3:
        g.setCoordinate(x, y + 1, v);
        if (x > xMax)
          xMax = x;
        if (y + 1 > yMax)
          yMax = y + 1;
        if (x < xMin)
          xMin = x;
        if (y + 1 < yMin)
          yMin = y + 1;
        break;
      }
    }
  }

  private void placePossibleVertices(Vertex v, Graph g) {
  }

  /*
   * private int getDensest(TreeMap<Integer, Integer> density, ArrayList<Integer>
   * exclude) {
   * 
   * }
   */

  public Grid<Vertex> arrangeGrid() {
    xMax = 0;
    yMax = 0;
    // generate density values
    int[] density = new int[nVerts];
    boolean[] visited = new boolean[nVerts];
    int maxIndex = 0;
    int placedVerts = 0;
    for (int i = 0; i < nVerts; i++) {
      for (int j = 0; j < nVerts; j++) {
        if (adjMat[i][j] != 0) {
          density[i]++;
        }
      }
      if (density[i] > density[maxIndex]) {
        maxIndex = i;
      }
    }

    TreeMap<Integer, Integer> densestUnsortedVar = new TreeMap();
    for (int i = 0; i < density.length; i++) {
      densestUnsortedVar.put(i, density[i]);
    }

    final TreeMap<Integer, Integer> densestUnsorted = densestUnsortedVar;

    Comparator<Integer> treeMapCompare = new Comparator<Integer>() {
      @Override
        public int compare(Integer K1, Integer K2) {
        int c = -1 * Integer.compare(densestUnsorted.get(K1), densestUnsorted.get(K2));
        return (c != 0 ? c : 1);
      }
    };
    TreeMap<Integer, Integer> densest = new TreeMap(treeMapCompare);
    densest.putAll(densestUnsorted);
    // System.out.println(densest);

    Grid<Vertex> g = new Grid(vertexList[densest.pollFirstEntry().getKey()]);
    // visited[currentVert] = true;

    x = 0;
    y = 0;

    // find all edges which must be attached to each vertex
    ArrayList<ArrayList<ArrayList<Edge>>> edgeFinder = new ArrayList();
    for (int i = 0; i < nVerts; i++) {
      edgeFinder.add(new ArrayList());
      for (int j = 0; j < nVerts; j++) {
        edgeFinder.get(i).add(getExtEdges(i, j));
      }
    }

    // temporary place vertices
    while (!densest.isEmpty()) {
      placeNextVert(vertexList[densest.pollFirstEntry().getKey()], g);
    }
    
    float xWidth = xMax - xMin;
    float yWidth = yMax - yMin;
    float xScale = (width * 2/5);
    float yScale = (height * 2/5);

    for (int i = 0; i < g.nodeList.size(); i++) {
      g.nodeList.get(i).data.x = (int) (((g.nodeList.get(i).x / xWidth) * xScale) + (width / 2) - (xScale / 2));
      g.nodeList.get(i).data.y = (int) (((g.nodeList.get(i).y / yWidth) * yScale) + (height / 2) - (yScale / 2));
    }

    return g;
  }
}
