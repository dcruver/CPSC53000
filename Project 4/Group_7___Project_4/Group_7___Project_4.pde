import java.text.DecimalFormat;
import java.text.NumberFormat;

import java.util.ArrayList;
import java.util.List;
import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;

//Screen and Plot Area Size Definitions
private static final int SCREEN_WIDTH = 1000;
private static final int SCREEN_HEIGHT = 600;
private static final int PLOT_AREA_TOP_LEFT_X = 100;
private static final int PLOT_AREA_TOP_LEFT_Y = 100;
private static final int PLOT_AREA_WIDTH = 700;
private static final int PLOT_AREA_HEIGHT = 400;

private static final String[] IMAGE_FILE_NAMES = {"Project4Splash2.jpg", "Project4Splash1.jpg"};

//Colors
private static final int ADJUSTED_VALUE_COLOR = #00ccff;
private static final int AXES_COLOR = #000000;
private static final int BACKGROUND_COLOR = #999966;
private static final int PLOT_COLOR = #ffffcc;
private static final int TEXT_COLOR = #000000;
private static final int UNADJUSTED_VALUE_COLOR = #ff5050;

//Font names
private static final String SUBTITLE_FONT_NAME = "NimbusSanL-BoldItal-14.vlw";
private static final String TITLE_FONT_NAME = "NimbusSanL-Bold-18.vlw";
private static final String LABEL_FONT_NAME = "NimbusSanL-ReguCond-12.vlw";

private static final NumberFormat currencyFormat = DecimalFormat.getCurrencyInstance();

private int[] fileYears = {2016, 2015, 2014, 2013, 2012, 2011, 2010, 2009, 2008, 2007, 2006};

private PFont titleFont;

private PFont subTitleFont;

private PFont labelFont;

private float dataMin;

private float dataMax;

private DataSet currentDataSet = null;

private List<DataSet> dataSets = new ArrayList<DataSet>();

private int currentRow = 0;

private List<Integrator> adjustedIntegrators = new ArrayList<Integrator>();

private List<Integrator> unAdjustedIntegrators = new ArrayList<Integrator>();

private List<Point> plotPoints = new ArrayList<Point>();

private Stack<PImage> imageStack;

private Queue<GridLineMode> gridModeQueue = new LinkedList<GridLineMode>();

void setup() {
  size(1000, 600, JAVA2D);
  
  initializeImageStack();
  initializeGridLineQueue();
  loadData();
  loadFonts();
  calculateMaxMin();
  this.adjustedIntegrators = initializeIntegrators("adjusted");
  this.unAdjustedIntegrators = initializeIntegrators("unadjusted");
  currencyFormat.setMaximumFractionDigits(0);
}

private void initializeGridLineQueue() {
  gridModeQueue.offer(GridLineMode.HORIZONTAL);
  gridModeQueue.offer(GridLineMode.BOTH);
  gridModeQueue.offer(GridLineMode.VERTICAL);
  gridModeQueue.offer(GridLineMode.NONE);
}

private void initializeImageStack() {
  imageStack = new Stack();
  
  for (String imageName : IMAGE_FILE_NAMES) {
    PImage image = loadImage(imageName);
    image.resize(SCREEN_WIDTH, SCREEN_HEIGHT);
    imageStack.push(image);
  }
}

private List<Integrator> initializeIntegrators(String zAxisName) {
  List<Integrator> integrators = new ArrayList<Integrator>();
  String[] xAxisNames = currentDataSet.getXAxisNames(zAxisName);
  
  for (int i = 1; i < xAxisNames.length; i++) {
    String xAxisName = xAxisNames[i];
    int value = (int) currentDataSet.getValue(xAxisName, currentRow, zAxisName).floatValue();
    Integrator integrator =  new Integrator(value);
    integrators.add(integrator);
    
    int offset = (i - 1) * (PLOT_AREA_WIDTH / (xAxisNames.length - 2));
    int newX = PLOT_AREA_TOP_LEFT_X + offset;
    int newY = getYForValue(value);
    plotPoints.add(new Point(newX, newY, value));
  }
  
  return integrators;
}

private void setIntegratorTargets(String zAxisName, List<Integrator> integrators) {
  calculateMaxMin();
  String[] xAxisNames = currentDataSet.getXAxisNames(zAxisName);
  
  for (int i = 0; i < integrators.size(); i++) {
    String xAxisName = xAxisNames[i+1];
    Integrator integrator = integrators.get(i);
    float value = currentDataSet.getValue(xAxisName, currentRow, zAxisName).floatValue();
    int intValue = (int) value;
    integrator.target(intValue);
    
    int offset = i * (PLOT_AREA_WIDTH / (integrators.size() - 1));
    int newX = PLOT_AREA_TOP_LEFT_X + offset;
    int newY = getYForValue(value);
    plotPoints.add(new Point(newX, newY, value));
  }
}

private void loadFonts() {
  this.subTitleFont = loadFont(SUBTITLE_FONT_NAME);
  this.titleFont = loadFont(TITLE_FONT_NAME);
  this.labelFont = loadFont(LABEL_FONT_NAME);
}

private void loadData() {
    for (int fileYear : fileYears) {
    DataSet dataSet = new DataSetBuilder()
      .year(fileYear)
      .file(fileYear + "Adjusted.csv", "adjusted")
      .file(fileYear + "Unadjusted.csv", "unadjusted")
      .columnMask("NAICS  Code")
      .columnMask("TOTAL")
      .rowMask(6, 0)
      .get();
    
    dataSets.add(dataSet);
  }
  
  currentDataSet = dataSets.get(0);
  calculateMaxMin();
}

void draw() {
  smooth();
  noStroke();
  background(BACKGROUND_COLOR);
  
  if (imageStack.size() > 0) {
    image(imageStack.peek(), 0, 0);
    return;
  }

  updateIntegrators(adjustedIntegrators);
  updateIntegrators(unAdjustedIntegrators);
  drawTitles();  
  drawPlotArea();
  drawXAxisLabels();
  drawYAxisLabels();
  drawLegend();
  plotData();
  handleHover();
}

private void updateIntegrators(List<Integrator> integrators) {
  for (Integrator integrator : integrators) {
    integrator.update();
  }
}

private void drawTitles() {
  textAlign(CENTER);
  fill(TEXT_COLOR);
  textFont(titleFont);
  text(currentDataSet.getDataSetTitle(), (SCREEN_WIDTH - 120) / 2, 30);
  textFont(subTitleFont);
  text(currentDataSet.getRowName("adjusted", currentRow), (SCREEN_WIDTH - 120) / 2, 50);
}

private void calculateMaxMin() {
  this.dataMin = ((int) currentDataSet.getRowMin("unadjusted", currentRow).floatValue() / 1000) * 1000 - 15000;
  this.dataMax = ((int) currentDataSet.getRowMax("unadjusted", currentRow).floatValue() / 1000) * 1000 + 1000;
}

private void drawLegend() {
  rectMode(CORNER);
  fill(PLOT_COLOR);
  rect(830, 200, 150, 75);
  noFill();
  stroke(TEXT_COLOR);
  rect(830, 200, 150, 75);
  fill(ADJUSTED_VALUE_COLOR);
  rect(850, 230, 6, 6);
  fill(UNADJUSTED_VALUE_COLOR);
  rect(850, 252, 6, 6);
  
  fill(TEXT_COLOR);
  textAlign(RIGHT);
  text("Legend", 880, 215);
  text("Adjusted Values", 948, 239);
  text("Unadjusted Values", 960, 260);
}

private void plotData() {
  plotIntegratorData(adjustedIntegrators, ADJUSTED_VALUE_COLOR);
  plotIntegratorData(unAdjustedIntegrators, UNADJUSTED_VALUE_COLOR);
}

private void plotIntegratorData(List<Integrator> integrators, int fillColor) {
  fill(fillColor);
  Integer x = null;
  Integer y = null;
  int i = 0;
  
  for (Integrator integrator : integrators) {
    int value = (int) integrator.value;
    int offset = i * (PLOT_AREA_WIDTH / (integrators.size() - 1));
    int newX = PLOT_AREA_TOP_LEFT_X + offset;
    int newY = getYForValue(value);
    
    if (i != 0) {
      line(x, y, newX, newY);
    }
    
    rect(newX - 3, newY - 3, 6, 6);
    x = newX;
    y = newY;
    i++;
  }
}

private void drawPlotArea() {
  rectMode(CORNER);
  noStroke();
  fill(PLOT_COLOR);
  rect(PLOT_AREA_TOP_LEFT_X, PLOT_AREA_TOP_LEFT_Y, PLOT_AREA_WIDTH, PLOT_AREA_HEIGHT);
  noFill();
  stroke(TEXT_COLOR);
  rect(PLOT_AREA_TOP_LEFT_X - 1, PLOT_AREA_TOP_LEFT_Y - 1, PLOT_AREA_WIDTH + 2, PLOT_AREA_HEIGHT + 2);
}

private void drawYAxisLabels() {
  textFont(labelFont);
  fill(AXES_COLOR);
  stroke(128);
  text("Million $", PLOT_AREA_TOP_LEFT_X - 30, PLOT_AREA_TOP_LEFT_Y - 10);
  
  int volumeIntervalMinor = (int) (dataMax - dataMin) / 10;
  
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) {
    float y = getYForValue(v);
    if (v == dataMin) {
      textAlign(RIGHT); // Align by the bottom
    } else if (v == dataMax) {
      textAlign(RIGHT, CENTER); // Align by the top
    } else {
      textAlign(RIGHT, CENTER); // Center vertically
    }
    
    String valueStr = DecimalFormat.getInstance().format(floor(v));
    text(valueStr, PLOT_AREA_TOP_LEFT_X - 15, y);
    
    int horizontalGridLineEnd = PLOT_AREA_TOP_LEFT_X;
    GridLineMode gridLineMode = gridModeQueue.peek();
    
    if (gridLineMode == GridLineMode.BOTH || gridLineMode == GridLineMode.HORIZONTAL) {
      horizontalGridLineEnd += PLOT_AREA_WIDTH;
    }
    
    line(PLOT_AREA_TOP_LEFT_X - 10, y, horizontalGridLineEnd, y);
  }
}

void drawXAxisLabels() {
  textFont(labelFont);
  fill(AXES_COLOR);
  stroke(128);
  String[] columnNames = currentDataSet.getXAxisNames("adjusted");
  int labelY = PLOT_AREA_TOP_LEFT_Y + PLOT_AREA_HEIGHT + 40;
  
  for (int i = 1; i < columnNames.length; i++) {
    int offset = (i - 1) * (PLOT_AREA_WIDTH / (columnNames.length - 2)) + 8;
    int labelX = PLOT_AREA_TOP_LEFT_X + offset;
    verticalText(columnNames[i], labelX, labelY);
    
    int verticalGridLineStart = PLOT_AREA_TOP_LEFT_Y;
    GridLineMode gridLineMode = gridModeQueue.peek();
    
    if (gridLineMode == GridLineMode.NONE || gridLineMode == GridLineMode.HORIZONTAL) {
      verticalGridLineStart += PLOT_AREA_HEIGHT;
    }
    
    line(labelX - 8, labelY - 30, labelX - 8, verticalGridLineStart);
  }
}

void verticalText(String text, int x, int y) {
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(x, y);
  rotate(-HALF_PI);
  text(text, 0, 0);
  popMatrix();
}

int getYForValue(float value) {
  return (int) max(map(value, this.dataMin, this.dataMax, PLOT_AREA_TOP_LEFT_Y + PLOT_AREA_HEIGHT, PLOT_AREA_TOP_LEFT_Y), 0);
}

void mouseWheel(MouseEvent event) {
  int currentIndex = dataSets.indexOf(currentDataSet);
  
  if (event.getCount() < 0 && currentIndex < dataSets.size() - 1) {
    currentDataSet = dataSets.get(currentIndex + 1);
  }
  
  if (event.getCount() > 0 && currentIndex > 0) {
    currentDataSet = dataSets.get(currentIndex - 1);
  }
  
  calculateMaxMin();
  plotPoints.clear();
  setIntegratorTargets("adjusted", adjustedIntegrators);
  setIntegratorTargets("unadjusted", unAdjustedIntegrators);
}

void keyPressed() {
  if (key == ' ') {
    if (imageStack.size() == 0) {
      gridModeQueue.offer(gridModeQueue.poll());
    } else {
      imageStack.pop();
    } 
  }
  
  if (imageStack.size() > 0) {
    return;
  }
  
  if (key == '[') {
    if (currentRow > 0) {
      currentRow--;
    }
  } 
  
  if (key == ']') {
    if (currentRow < currentDataSet.getRowCount("adjusted") - 1) {
      currentRow++;
    }
  }
  
  calculateMaxMin();
  plotPoints.clear();
  setIntegratorTargets("adjusted", adjustedIntegrators);
  setIntegratorTargets("unadjusted", unAdjustedIntegrators);
}

private void handleHover() {
  fill(TEXT_COLOR);
  
  for (Point point : plotPoints) {
    if (containsMouse(point)) {
      String valueStr = currencyFormat.format(point.getValue());
      text(valueStr, point.x + 19, point.y - 7);
    }
  }
}

private boolean containsMouse(Point point) {
  return abs(mouseX - point.x) < 6 &&
         abs(mouseY - point.y) < 6;
}