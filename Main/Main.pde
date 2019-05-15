
WGraph g = new WGraph();

int selectedVert = -1;
int frame = 0;
float SPINOFFSET = 0;
boolean spin = false;
boolean gettingWeight = false;
boolean addingEdge = false;
boolean selectFactor = false;
int factorLoc = 1;
int edgeVert1 = -1;
int edgeVert2 = -1;
int edgeWeight;
PFont f;

void setup() {
  surface.setResizable(true);
  WIDTH = (int) (width * 0.35);
  CENTERX = width / 2;
  CENTERY = height / 2;
  f = createFont("Arial", 16, true);
  size(750, 750);
  background(255, 255, 255);
  strokeWeight(2);

  textFont(f, 16);
  fill(255);

  g.dynWeight = true;

  g.addVertex('A'); // 0
  g.addVertex('B'); // 1
  g.addVertex('C'); // 2
  g.addVertex('D'); // 3
  g.addVertex('E'); // 4

  g.addEdge(0, 1, 1);
  g.addEdge(0, 2, 1);
  g.addEdge(0, 3, 1);
  g.addEdge(0, 4, 1);
  g.addEdge(1, 2, 1);
  g.addEdge(1, 3, 1);
  g.addEdge(1, 4, 1);
  g.addEdge(2, 3, 1);
  g.addEdge(2, 4, 1);
  g.addEdge(3, 4, 1);


  textAlign(CENTER, CENTER);

  // g.arrangeCircle(true);
  g.calcDensity();
  g.arrangeAnnealing(10);
  g.edgeFactor = 100;
  for (int i = 0; i < g.nVerts; i++) {
    for (int j = 0; j < g.nVerts; j++) {
      if (g.adjMat[i][j] != 0) {
        g.adjMat[i][j] = (int) Math.sqrt(Math.pow(g.vertexList[i].x - g.vertexList[j].x, 2) + Math.pow(g.vertexList[i].y - g.vertexList[j].y, 2));
      }
    }
  }
  // spin = true;
  // g.genGraph();

  fill(0);
}

void draw() {
  if (spin) {
    SPINOFFSET += PI/300;
    SPINOFFSET %= 2*PI;
    g.arrangeCircle(false);
  }

  WIDTH = (int) (Math.min(width, height) * 0.35);
  CENTERX = width / 2;
  CENTERY = height / 2;
  clear();
  background(255);
  strokeWeight(2);
  if (selectedVert != -1) {
    g.vertexList[selectedVert].setCoords(mouseX, mouseY);
    if (g.dynWeight) {
      for (int i = 0; i < g.nVerts; i++) {
        if (g.adjMat[selectedVert][i] != 0) {
          g.adjMat[selectedVert][i] = (int) Math.sqrt(Math.pow(g.vertexList[selectedVert].x - g.vertexList[i].x, 2) + Math.pow(g.vertexList[selectedVert].y - g.vertexList[i].y, 2));
          g.adjMat[i][selectedVert] = g.adjMat[selectedVert][i];
        }
      }
    }
    if (g.pathing && g.dynWeight) {
      g.path(g.pathStart, g.pathEnd);
    }
  }

  // select vertex box
  if (g.selectingVertex) {
    fill(0, 190, 0);
  } else {
    fill(255, 0, 0);
  }
  noStroke();
  rect(width - 300, 0, 300, 75);
  fill(255);
  stroke(0);
  textAlign(LEFT, CENTER);
  textFont(createFont("Arial", 20, true));
  if (!g.selectingVertex) {
    text("Click here to compute a path", width - 280, 38);
  } else {
    if (g.chooseV1) {
      text("Choose the first vertex.", width-280, 38);
    } else {
      text("Choose the second vertex.", width-280, 38);
    }
  }

  fill(255, 0, 0);
  noStroke();
  rect(width - 300, 85, 300, 75);
  if (g.selectingEdge) {
    fill(0, 190, 0);
  }
  rect(width - 300, 170, 300, 75);
  fill(255);
  stroke(0);
  text("Click here to add a vertex", width - 280, 85+38);
  if (!g.selectingEdge) {
    text("Click here to add/edit an edge", width - 280, 170+23);
    text("Length is distance on the canvas", width - 295, 170+23+20);
  } else {
    if (g.chooseV1) {
      text("Select first vertex", width - 280, 170+38);
    } else {
      text("Select second vertex", width - 280, 170+38);
    }
  }
  textFont(f, 16);
  textAlign(CENTER, CENTER);
  fill(255);

  // arrangement buttons
  fill(0);
  noStroke();
  rect(0, 50, 250, 75);
  rect(0, 135, 250, 75);
  rect(0, 220, 250, 75);
  stroke(0);
  fill(255);
  textAlign(LEFT, CENTER);
  textFont(f, 20);
  text("Arrange in a circle", 20, 50+38);
  text("Arrange in a grid", 20, 135+38);
  text("Arrange using annealing", 20, 220+38);

  // dynamic weights checkbox
  strokeWeight(6);
  fill(255);
  rect(3, 3, 37, 37);
  stroke(0, 255, 0);
  if (g.dynWeight) {
    line(10, 20, 20, 35);
    line(20, 35, 35, 10);
  }
  fill(0);
  stroke(0);
  textAlign(LEFT, CENTER);
  textFont(f, 20);
  text("Dynamic Weights", 55, 20);
  textFont(f, 16);
  fill(255);
  strokeWeight(2);

  // slider
  fill(0);
  line(width - 290, 285, width - 100, 285);
  text("1", width - 300, 285);
  text("100", width - 95, 285);
  stroke(0);
  line(width - 290 + factorLoc, 270, width - 290 + factorLoc, 300);

  textFont(f, 10);
  text("Edge length multiplier", width - 225, 265);
  textFont(f, 16);
  textAlign(CENTER, CENTER);
  text(g.edgeFactor + "%" + (g.edgeFactor == 0 ? " (Delete)" : ""), width - 195, 300);
  text("Previous edge: " + g.prevEdgeLen * g.edgeFactor / 100, width - 195, 320);
  if (selectFactor) {
    factorLoc = Math.min(Math.max(mouseX, width - 290), width - 100) - width + 290;
    g.edgeFactor = 100 - (factorLoc * 100 / 190);

    // println(g.edgeFactor);
  }

  g.drawPoints();
}

void mousePressed() {
  if (mouseButton == LEFT) {
    boolean s = false;
    if (selectFactor) {
      selectFactor = false;
      s = true;
    }
    if (!s && mouseX > width - 291 + factorLoc && mouseX < width - 285 + factorLoc && mouseY > 270 && mouseY < 300) {
      selectFactor = true;
    }
    if (!selectFactor) {
      if (!(g.selectingVertex || g.selectingEdge)) {
        selectedVert = g.selectVert(selectedVert);
        spin = false;
      } else {
        g.selectVert(-1);
      }
      if (mouseX > width - 300 && mouseY < 75) {
        g.selectingVertex = true;
        g.chooseV1 = true;
      } else if (mouseX > width - 300 && mouseY > 85 && mouseY < 85+75) {
        g.addVertex((char)('A'+g.nVerts+1));
        g.calcDensity();
        selectedVert = g.nVerts - 1;
      } else if (mouseX > width - 300 && mouseY > 170 && mouseY < 170+75) {
        g.selectingEdge = true;
        g.chooseV1 = true;
      } else if (mouseX < 40 && mouseY < 40) {
        g.dynWeight = !g.dynWeight;
        for (int i = 0; i < g.nVerts; i++) {
          for (int j = 0; j < g.nVerts; j++) {
            if (g.adjMat[i][j] != 0) {
              g.adjMat[i][j] = (int) Math.sqrt(Math.pow(g.vertexList[i].x - g.vertexList[j].x, 2) + Math.pow(g.vertexList[i].y - g.vertexList[j].y, 2));
            }
          }
        }
        if (g.pathing) {
          g.path(g.pathStart, g.pathEnd);
        }
      } else if (mouseX < 250 && mouseY > 50 && mouseY < 50+75) {
        g.arrangeCircle(true);
        spin = true;
      } else if (mouseX < 250 && mouseY > 135 && mouseY < 135+75) {
        g.arrangeGrid();
        spin = false;
      } else if (mouseX < 250 && mouseY > 220 && mouseY < 220+75) {
        g.arrangeAnnealing(10);
        for (int i = 0; i < g.nVerts; i++) {
          for (int j = 0; j < g.nVerts; j++) {
            if (g.adjMat[i][j] != 0) {
              g.adjMat[i][j] = (int) Math.sqrt(Math.pow(g.vertexList[i].x - g.vertexList[j].x, 2) + Math.pow(g.vertexList[i].y - g.vertexList[j].y, 2));
            }
          }
        }
      }
    }
  }
}
