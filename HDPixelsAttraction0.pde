
import generativedesign.*;
import processing.pdf.*;
import java.util.Calendar;
import java.util.Date;

boolean savePDF = false;
boolean saveToPrint = false;
boolean recording = false;

int h=1600;
int w=1600;

float cnt01, cnt02;
int currentDrawIterationForCluster = 0;
float valenceMean ; //calculated inside load data
float pointX, pointY; //used for mapping X and Y position of attractors
int count = 250; //int(random(40,90)); //number of dots
int crclSize=w/2-200;
int crclDist=int(sqrt(pow(crclSize, 2)/2));

//attractors parameters
int radius; //radius for attractors
float ramp; //ramp default before mapping

String fileName="0F.csv";

int clusterCount = 2; //number of clusters  ******
int time = clusterCount*120;

int c1x = int(map(-1.50228259, -2, 2, w/2-crclDist, w/2+crclDist));     //mapping mean of first cluster for x,y positions
int c1y = int(map(1.39148265, 2, -2, w/2+crclDist, w/2-crclDist));
int r1 = int(map(31, 0, 150, 100, 800));        //mapping radius to be each cluster's size

int c2x = int(map(0.4786033, -2, 2, w/2-crclDist, w/2+crclDist));     //mapping mean of second cluster for x,y positions
int c2y = int(map(-0.44330421, 2, -2, w/2+crclDist, w/2-crclDist));
int r2 = int(map(108, 0, 150, 100, 800));

int c3x = int(map(0, -2, 2, 150, w-150));     //mapping mean of third cluster for x,y positions
int c3y = int(map(0, 2, -2, h-150, 0+150));
int r3 = int(map(0, 0, 150, 100, 800));

int c4x = int(map(0, -2, 2, 150, w-150));     //mapping mean of 4 cluster for x,y positions
int c4y = int(map(0, 2, -2, h-150, 0+150));
int r4 = int(map(0, 0, 150, 100, 800));

int c5x = int(map(0, -2, 2, 150, w-150));     //mapping mean of 5 cluster for x,y positions
int c5y = int(map(0, 2, -2, h-150, 0+150));
int r5 = int(map(0, 0, 150, 100, 800));

int c6x = int(map(0, -2, 2, 150, w-150));     //mapping mean of 6 cluster for x,y positions
int c6y = int(map(0, 2, -2, h-150, 0+150));
int r6 = int(map(0, 0, 150, 100, 800));


float noise= 10*100/150 ; // noise in percentage, based on number of noise points (first number) in DBSCAN  ************* 

int drawingRadius= int(map(noise, 0, 100, 100, 600));

float strength = 45*int(random(-2, 2));//map(0.9, 0, 1, 0, 45); //strength of attractors
float rampS= 0.19;                // ramp on starting= initial point effect           

float circleRadius = map(100-noise, 0, 100, 0.98, 1); //how spreaded are the initial points around the circle 

float finalnodeY, finalnodeX;
color range;
int coloredline;

int left [][]=new int [2][count]; //2 2D arrays with values
int right [][]=new int [2][count];

int xCount=0; //initial value

ArrayList<ClusterXY> clusterStartPoints = new ArrayList<ClusterXY>();

ArrayList<Node> nodeArraylist; //vsetky spolu
ArrayList<ArrayList> linesList; //vsetky lines

Attractor myAttractor;

PointAnna[]points;

Table table;

void setup() {
  size(1600, 1600); 
  smooth();
  pixelDensity(2);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  loadData();
  setupClusterPoints();

  float mappedValence=map(valenceMean, 1, -1, count-20, 20);
  coloredline=floor(mappedValence);
  int colorMapped=int(map(valenceMean, 1, -1, 340, 220));

  colorMode(HSB, 360, 100, 100);
  range=color(colorMapped, 42, 73);

  ramp = map(valenceMean, -1, 1, -0.99, 0.99); //ramp radius to be based on valence

  println("points= " +count + " strength= " + strength+" ramp= " +ramp+ " radius= " +radius+ " colored line=" +coloredline +" noise= " +noise );

  makepoints(); //calculates the positions of points around a circle, and stores them in the 2D arrays. if circleRadius not 1, they are more spread, not following a clear circle line
  sortMe(left); //sorting all left points by y value, smallest to highest
  sortMe(right);

  nodeArraylist = new ArrayList<Node>(10000);
  linesList=new ArrayList();

  initGrid(); // setup node grid. This is where I save the position of each node (from all the lines) into the array.

  myAttractor = new Attractor(0, 0); // setup attractor
  myAttractor.strength = strength;
  myAttractor.ramp = ramp;
  myAttractor.radius=radius;
}

boolean first=true;
int c = 0;
//float noiseMax = map(noise, 0, 100, 1, 5);

void setupClusterPoints()
{
  for (int i=0; i< clusterCount; i++)
  {
    if (i==0)
      clusterStartPoints.add(new ClusterXY(c1x, c1y, r1));
    else if (i==1)
      clusterStartPoints.add(new ClusterXY(c2x, c2y, r2));
    else if (i==2)
      clusterStartPoints.add(new ClusterXY(c3x, c3y, r3));
    else if (i==3)
      clusterStartPoints.add(new ClusterXY(c4x, c4y, r4));
    else if (i==4)
      clusterStartPoints.add(new ClusterXY(c5x, c5y, r5));
    else if (i==5)
      clusterStartPoints.add(new ClusterXY(c6x, c6y, r6));
  }
}


void draw() {

  if (savePDF) beginRecord(PDF, fileName+ c+".pdf");

  background(0, 0, 100);
  strokeWeight(0.3);
  stroke(0);
  fill(0);
  float lastx=0;
  float lasty=0;

  float directionx=random(-1, 1);
  float directiony=random(-1, 1);
  int randomizedDrawingRadiusX=int(random(0, drawingRadius)*directionx);
  int randomizedDrawingRadiusY=int(random(0, drawingRadius)*directiony);

  ClusterXY currentClusterPoint = clusterStartPoints.get(currentDrawIterationForCluster);

  pointX = currentClusterPoint.x;
  pointY = currentClusterPoint.y;
  myAttractor.radius=currentClusterPoint.radius;

  currentDrawIterationForCluster++;

  c++;
  cnt01+=0.7;
  cnt02+=0.34;

  if (first) {
    myAttractor.ramp = rampS;
    myAttractor.radius = 150;
    myAttractor.x = pointX;
    myAttractor.y = pointY;

    //first=false;
  } else {
    myAttractor.ramp = ramp;
    myAttractor.x = pointX+(noise(cnt01)-0.5)*350-randomizedDrawingRadiusX;
    myAttractor.y = pointY+(noise(cnt02)-0.5)*350-randomizedDrawingRadiusY;
  }

  if (c%20==0 & directionx<0)myAttractor.strength*=-1;

  //if(c%30==0 & directionx>0)myAttractor.strength= int(random(25,45))*directionx;

  for (int i = 0; i < linesList.size(); i++) {  //loop for going through the nodes drawing them, and updating their position.
    ArrayList pointsOnLine=linesList.get(i);

    if (i==coloredline ||i==coloredline-2 || i==coloredline+2) {
      stroke(range); 
      strokeWeight(0.8);
    } else {
      stroke(0);
      strokeWeight(0.3);
    }

    for (int j=0; j<pointsOnLine.size(); j++) {
      Node node = (Node)pointsOnLine.get(j);
      myAttractor.attract(node);
      node.update();    

      finalnodeX=node.x;
      finalnodeY=node.y;      

      if (lastx>0) {      
        line(finalnodeX, finalnodeY, lastx, lasty);
      }
      lastx=finalnodeX;
      lasty=finalnodeY;
    }

    lastx=0;
    lasty=0;
  }


  if (currentDrawIterationForCluster==clusterCount)
  {
    currentDrawIterationForCluster = 0;
    first=false;
  }



  if (recording)saveFrame("output/attractingPixs_####.png");

  if (c%50==0)
  {
    println("saving shot");
    saveFrame(timestamp()+"_####.png");
  }

  if (c==time)
  {
    println("I'm done. Thanks");
    saveFrame(timestamp()+"_####.png");
    noLoop();
  }

  if (savePDF) {
    savePDF = false;
    println("saving to pdf – finishing");
    endRecord();
  }
}

void loadData() {

  Table table = loadTable(fileName); //data file
  float[][] points = new float[2][table.getRowCount()-1];


  for (int i=1; i<table.getRowCount(); i++) { //accesing all table rows and storing them as object parameters

    TableRow row=table.getRow(i);

    float xax=(float)row.getDouble(4); 
    float yax =(float)row.getDouble(5); 


    points[0][i-1] = xax;
    points[1][i-1] = yax;
  }

  float[] meanX = meanAndStd(points[0]);
  float[] meanY = meanAndStd(points[1]);
  println(" mean for valence and arousal  is " + meanX[0], meanY[0]);
  println("std  is " + meanX[1], meanY[1]);
  valenceMean= meanX[0];
  //arousalMean=meanY[0];
  //valenceStd=meanX[1]; 
  //arousalStd=meanY[1];
}

float[] meanAndStd(float numArray[])
{
  float[] ret = new float[2];
  float sum = 0.0, standardDeviation = 0.0;
  int length = numArray.length;

  for (float num : numArray) {
    sum += num;
  }

  float mean = sum/length;

  for (float num : numArray) {
    standardDeviation += Math.pow(num - mean, 2);
  }

  ret[0] = mean;
  ret[1] = (float)Math.sqrt(standardDeviation/length);

  return ret;
}

void sortMe(int[][] arr) {
  String [] sortArray= new String[count];


  for (int j = 0; j < count; ++j) {       //Moving the data from Matrix to single array to be sorted
    String combineColumns; 
    combineColumns = str(arr[0][j]);   //Adding the two columns together, seperated by a "dash(-)"  
    //Converting the datatype to String, to fit a single array
    combineColumns = str(arr[1][j]) + "-" + combineColumns; //saving string with y position first
    sortArray[j] = combineColumns;
  }

  sortArray = sort(sortArray);  //Sorting, using processings sorting function

  for (int i = 0; i < count; ++i) {  //Moving the sorted data back in the Matrix
    String[] tmp = split(sortArray[i], "-"); //Using the split function, for each string in my array, and input the data into a temporary array (holding 2 numbers(rows))    
    arr[0][i] = int(tmp[1]); 
    arr[1][i] = int(tmp[0]); //Using the temp array, to write the data into the matrix again, flipping x,y position back
  }

  // println(""); println("FINAL RESULT"); //checking if sorting worked
  //for(int i = 0; i < 10; ++i) {
  // print(arr[0][i],arr[1][i]);
  // println("");
  //}
}

void makepoints() {

  for (int i=0; i<count; i++) {   //calculating coordinates for each point on the right side

    float angle = radians(180/float(count));
    float randomX = random(0, width);  
    float randomY = random(0, height);
    float circleX = width/2 + sin(angle*i)*(crclSize);
    float circleY = height/2 + cos(angle*i)*(crclSize);

    int x = floor(lerp(randomX, circleX, circleRadius)); 
    int y = floor(lerp(randomY, circleY, circleRadius));

    right [0][i]=x;
    right [1][i]=y;
  }


  for (int i=0; i<count; i++) {  //calculating coordinates for each point on left side
    float angle = radians(-180/float(count));
    float randomX = random(0, width);  
    float randomY = random(0, height);
    float circleX = width/2 + sin(angle*i)*(crclSize);
    float circleY = height/2 + cos(angle*i)*(crclSize);

    int x = floor(lerp(randomX, circleX, circleRadius)); 
    int y = floor(lerp(randomY, circleY, circleRadius));

    left [0][i]=x;
    left [1][i]=y;
  }
}

void initGrid() {


  for (int y = 0; y < count; y++) {

    int middleToPoint = int(dist(width/2, left[1][y], left[0][y], left[1][y]));

    ArrayList<Node> nodesInOneLine =new ArrayList(); //vsetky body v jednej line

    for (int x = left[0][y]; x <= left[0][y]+2*middleToPoint; x++) {
      int xPos = x;
      int yPos = left[1][y];    

      Node myOneNode = new Node(xPos, yPos); //save position in Node object
      myOneNode.setBoundary(0, 0, width, height);
      myOneNode.setDamping(0.8);  //// 0.0 - 1.0

      nodeArraylist.add(myOneNode);
      nodesInOneLine.add(myOneNode);
    }

    linesList.add(nodesInOneLine);
  }
}


/////

void keyReleased() {  //saving
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_####.png");
  if (key == 'p' || key == 'P') savePDF = true; 
  println("I'm safed!");
  if  (key == 'r' || key == 'R') {
    recording = !recording; 
    if (recording) println("recording on");
    if (!recording) println("recording stopped");
  }
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
