// Carbon Emissions in the United States
// by Sam Slover for Data Rep at ITP, Sept 28
// www.athinkingsam.com

// preload all images
/* @pjs preload="texture.png";*/
/* @pjs font="Quantico-Regular.ttf"; */

int screenWidth = 980;
int screenHeight = 790;

// arrays for data
// the entire spreadsheet
String [] cells;
// split it in this array
String [] splits;
// array for the emissions
Float [] emissions;
// array for the abbreviatios
String [] abbreviations;

// create arraylist to hold State objects
ArrayList<State> states;

PShape usa;
PFont myFont;
PImage texture;

Button button1;

void setup() {
  size(screenWidth, screenHeight);

  // set up font for sketch
  myFont = createFont("Quantico-Regular.ttf", 48);
  textFont(myFont);

  //load map of usa
  usa = loadShape("usa-wikipedia-2.svg");

  // load image needed to make smoke
  texture = loadImage("texture.png");

  // arraylist to hold State objects  
  states = new ArrayList<State>();
  createStates();

  button1 = new Button (60, height - 120, 220, 40);
}

void draw() {

  background(20, 20, 20);
  button1.display();
//  textFont(myFont);
//  textSize(48);
//  textAlign(CENTER, CENTER);
//  fill(235,235,200);
//  text("One Nation Under", width/2 - 50, 80);
//  fill(250,40,20);  
//  text("CO2", width/2+208, 80);
  
  //create key
  createKey();
  if (button1.pressed == false) {
    shape(usa, 0, 0);
    button1.buttonText = "Click to See Data";
    for (int i = states.size()-1; i >= 0; i--) {
      State s = (State) states.get(i);
      s.display();
    }

    for (int i = states.size()-1; i >= 0; i--) {
      State s = (State) states.get(i);
      s.runSmoke(s.abbrev);
    }
  }

  else {
    button1.buttonText = "Click to See Map";
    int startingPoint = 10; 
    int currentMax = 0;
    for (int i = states.size()-1; i >= 0; i--) {
      State s = (State) states.get(i);
      int numOfBlocks;
      numOfBlocks = int(map(s.emissions, 3.9, 380, 1, width/22));
      s.drawChart(startingPoint, numOfBlocks);
      startingPoint+= 12;
      if (i == 0) {
        textSize(16);
        textAlign(LEFT, CENTER);
        text("All Figures in Million Metric Tonnes of Carbon Dioxide", 10, startingPoint+12);
      }
    }
  }
}

void createStates() {
  //load data
  cells = loadStrings("us-carbon-emissions.csv");
  abbreviations = new String[cells.length];
  emissions = new Float[cells.length];
  for (int i = 0; i < cells.length; i++) {
    splits = cells[i].split(",");
    abbreviations[i] = splits[0];
    emissions[i] = float(splits[6]);
    State s = new State (abbreviations[i], emissions[i]);
    states.add(s);
  }
}

void createKey() {
  float colorR = 235;
  float colorG;
  float colorB;
  int xPoint = width/2 - 80;
  int yPoint = height - 120;
  for (int i=0; i<=100; i++) {
    colorG = map(i, 0, 100, 255, 0);
    colorB = map(i, 0, 100, 215, 0);
    fill(colorR, colorG, colorB);
    rect(xPoint, yPoint, 5, 40);
    //add some labels at key points
    if (i == 0) {
      textAlign(LEFT, CENTER);
      textFont(myFont, 16);
      text("Lowest Emittors", xPoint, yPoint + 50);
      textFont(myFont, 10);
      text("4 MMTCDE (Wash DC)", xPoint, yPoint + 70);
      text("*MMTCDE = Million Metric Tonnes of Carbon Dioxide", xPoint, yPoint + 85);
    }

    if (i == 100) {
      textAlign(RIGHT, CENTER);
      textFont(myFont, 16);
      text("Highest Emittors", xPoint+5, yPoint + 50);
      textFont(myFont, 10);
      text("625 MMTCDE (TEXAS)", xPoint, yPoint + 70);
    }

    xPoint+=5;
  }
}

void mousePressed() {
  if (mouseX >= button1.x && mouseX <= button1.x + button1.w && mouseY >= button1.y && mouseY <= button1.y + button1.h) {
    button1.buttonPressed();
  }
}

// Main State Class //

class State {
  PShape s;
  float colorR = 235;
  float colorG;
  float colorB;
  color col;
  String abbrev;
  Float emissions; 
  float x;
  float y;
  PImage img;
  SmokeSystem ss;

  State (String _abbrev, Float _emissions) {
    abbrev = _abbrev;
    emissions = _emissions;

    //first, let's change the size of the smoke to the amount of emissions
    int smokeSize = int(map(emissions, 3.9, 625, 1, 50));
    PImage tempImg = texture.get(0, 0, 32, 32); 
    tempImg.resize(smokeSize, 0);

    ss = new SmokeSystem(0, new PVector(x, y), tempImg);
  }

  void display() {
    s = usa.getChild(abbrev);
    s.disableStyle();
    noStroke();
    colorG = map(emissions, 3.9, 380, 255, 0);
    colorB = map(emissions, 3.9, 380, 215, 0);
    fill(colorR, colorG, colorB);
    shape(s, 0, 0);

    col = color(colorR, colorG, colorB);
  }

  void runSmoke(String abbrev) {
    s = usa.getChild(abbrev);

    float minX = 10000;
    float maxX = 0;
    float minY = 10000;
    float maxY = 0;

    for (int i = 0 ; i < s.getVertexCount(); i++) {
      float tempX = s.getVertexX(i);
      float tempY = s.getVertexY(i);
      if (tempX > maxX) {
        maxX = tempX;
      }
      if (tempX < minX) {
        minX = tempX;
      }
      if (tempY > maxY) {
        maxY = tempY;
      }
      if (tempY < minY) {
        minY = tempY;
      }

      x = (maxX + minX) / 2;
      y = (maxY + minY) / 2; 

      // need to handle Florida and Michigan anomalies
      if (abbrev.equals("FL") == true) {
        x = x + 50;
      }
      if (abbrev.equals("MI") == true) {
        x = x + 30;
        y = y + 30;
      }
      if (abbrev.equals("CA") == true) {
        x = x - 20;
      }
      if (abbrev.equals("TX") == true) {
        x = x + 15;
      }
    }

    // now, let's set the origin to the x and y we computed above
    ss.origin = new PVector (x, y);
    float ranX = random(-0.1, 0.1);
    float ranY = random(-0.1, 0);
    ss.applyForce(new PVector(ranX, ranY));
    ss.run();
    for (int i = 0; i < 2; i++) {
      ss.addParticle();
    }
  }

  void drawChart(int startingPoint, int numOfBlocks) {
    int chartX = 35;
    textSize(10);
    textAlign(LEFT, CENTER);
    text(abbrev, 10, startingPoint+3);
    for (int i=0; i<=numOfBlocks; i++) {
      fill(col);
      rect(chartX, startingPoint, 7, 7);
      chartX += 12;
      if (i == numOfBlocks){
        int emissionsTemp = int(emissions);
        text(emissionsTemp, chartX, startingPoint+3);
      }
    }
  }
}


// Button Class //
class Button {
  int x;
  int y;
  int w;
  int h;
  String buttonText = "Click to See Data";
  boolean pressed = false;

  Button (int _x, int _y,int _w,int _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }

  void display(){
    noStroke();
    fill(52,152,219);
    rect(x,y,w,h);
    textSize(16);
    fill(255);
    textAlign(LEFT,CENTER);
    text(buttonText, 105, height-102);  
}

  void buttonPressed(){
    pressed = !pressed;
  }
}

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  float lifespan;
  PImage img;

  Particle(PVector l,PImage img_) {
    acc = new PVector(0,0);
    float vx = randomGaussian()*0.3;
    float vy = randomGaussian()*0.3 - 1.0;
    vel = new PVector(vx,vy);
    loc = l.get();
    lifespan = 300.0;
    img = img_;
  }

  void run() {
    update();
    render();
  }
  
  // Method to apply a force vector to the Particle object
  // Note we are ignoring "mass" here
  void applyForce(PVector f) {
    acc.add(f);
  }  

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    lifespan -= 2.5;
    acc.mult(0); // clear Acceleration
  }

  // Method to display
  void render() {
    imageMode(CENTER);
    tint(255,lifespan);
    image(img,loc.x,loc.y);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

// Smoke Particle System

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class SmokeSystem {

  ArrayList<Particle> particles;    // An arraylist for all the particles
  PVector origin;        // An origin point for where particles are birthed
  PImage img;

  SmokeSystem(int num, PVector v, PImage img_) {
    particles = new ArrayList<Particle>();              // Initialize the arraylist
    origin = v.get();                        // Store the origin point
    img = img_;
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, img));    // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }

  // Method to add a force vector to all particles currently in the system
  void applyForce(PVector dir) {
    // Enhanced loop!!!
    for (Particle p: particles) {
      p.applyForce(dir);
    }
  }  

  void addParticle() {
    particles.add(new Particle(origin, img));
  }

}