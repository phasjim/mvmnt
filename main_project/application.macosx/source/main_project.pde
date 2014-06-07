/**
 * MVMNT
 * BY PRITA PRISCILLA HASJIM
 *
 * For more information go to pritahsjm.tumblr.com/icam160
 * or visit www.pritahasj.im.
 */

PFont clock_font;


PImage currFrame;      // current frame we are looking at
PImage prevFrame;      // previous frame that we are looking at
PImage bgFrame;        // current background image

int WIDTH = 0;
int HEIGHT = 0;

final float threshold = 30;  // threshold number to indicate change between frams

final int BLACK = 0;
final int WHITE = 1;
final int TOTALPIXELS = 400000;

int[] framePixels = new int[TOTALPIXELS]; // framePixels will contain the black (0, no change)
                                          // and white (1, yes change) pixel data that shows change
                                                                                    
color[] colorPixels = new color[TOTALPIXELS]; // colorPixels will contain the current RGB-color
                                              // in the indexed location

float[] rValues = new float[TOTALPIXELS]; // all current r-values
float[] gValues = new float[TOTALPIXELS]; // all current g-values
float[] bValues = new float[TOTALPIXELS]; // all current b-values

// stream image
String streamImg = "http://132.239.12.145/axis-cgi/jpg/image.cgi?resolution=640x400";

// background images
String sbgMain = "bg/main.png";  String sbgIdle = "bg/idle.png";  String sbg0 = "bg/00.png";
String sbg1 = "bg/01.png";       String sbg2 = "bg/02.png";       String sbg3 = "bg/03.png";
String sbg4 = "bg/04.png";       String sbg5 = "bg/05.png";       String sbg6 = "bg/06.png";
String sbg7 = "bg/07.png";       String sbg8 = "bg/08.png";       String sbg9 = "bg/09.png";

PImage bgMain;  PImage bgIdle;   PImage bg0;
PImage bg1;     PImage bg2;      PImage bg3;
PImage bg4;     PImage bg5;      PImage bg6;
PImage bg7;     PImage bg8;      PImage bg9;

boolean isMainBG = true;
int bgCounter = 0;    // tells us which bg we're on
int frameChange = 0;  // variable that changes the frame

/** ---------------------------------------------------------------------------------
 * setup() does the default settings for the frame
 * ----------------------------------------------------------------------------------
 */
void setup() {
  size(800, 500);       // sets the size
  background(50);        // sets background
  noStroke();            // sets no stroke
  
  currFrame = loadImage(streamImg, "jpg");
  currFrame.resize(800,0);
  
  setupBackground();
  
  // sets up these global variables
  WIDTH = currFrame.width;
  HEIGHT = currFrame.height;
    
  clock_font = loadFont("data/NewsGothicMT-Italic-48.vlw");
  textFont(clock_font, 30);
  
} // end setup()



/** ---------------------------------------------------------------------------------
 * setupBackground() sets up the different background images
 * ----------------------------------------------------------------------------------
 */
void setupBackground() {
  // initializes all of the backgrounds
  bgIdle = loadImage(sbgIdle, "png");
  bgMain = loadImage(sbgMain, "png");
  bg0 = loadImage(sbg0, "png");
  bg1 = loadImage(sbg1, "png");
  bg2 = loadImage(sbg2, "png");
  bg3 = loadImage(sbg3, "png");
  bg4 = loadImage(sbg4, "png");
  bg5 = loadImage(sbg5, "png");
  bg6 = loadImage(sbg6, "png");
  bg7 = loadImage(sbg7, "png");
  bg8 = loadImage(sbg8, "png");
  bg9 = loadImage(sbg9, "png");
  
  // sets initial background
  bgFrame = bgMain;
  
  tint(180, 180, 180, 50);
  image(bgFrame, 0, 0);
  
} // end setup()



/** ---------------------------------------------------------------------------------
 * draw() is the main method
 * ----------------------------------------------------------------------------------
 */
void draw() {
  
  // MVMNT only runs 6am - 6pm (6:00 - 18:00)
  if((int)hour() >= 6 && (int)hour() < 18){
    compareFrames();
    drawBackground();
    changeBackground();
    drawCanvas();
  }
  else{
    drawIdle();
  }
  
  // debug statements
  // debugPrint();
  
} // end draw()


/** ---------------------------------------------------------------------------------
 * drawIdle() draws the idle state
 * ----------------------------------------------------------------------------------
 */
void drawIdle() {
  image(bgIdle, 0, 0);
  
  fill(255, 180);
  textAlign(CENTER);
  text("sorry, MVMNT only runs between 6am to 6pm everyday.", width/2, height/4);
  text("please check back another time.", width/2, height/4 + 25);

  
  String displayHour = "" + (int)hour();
  String displayMin = "" + (int)minute();
  String displaySec = ""+ (int)second();
  
  if((int)hour()   < 10) displayHour = "0" + displayHour;
  if((int)minute() < 10) displayMin = "0" + displayMin;
  if((int)second() < 10) displaySec = "0" + displaySec;
  
  textAlign(CENTER);
  text(displayHour + " : " + displayMin + " : " + displaySec, width/2, height/4 * 3);
  
} // end drawIdle()



/** ---------------------------------------------------------------------------------
 * debugPrint() prints out debug statements. Should be commented out for the final
 * project...
 * ----------------------------------------------------------------------------------
 */
void debugPrint() {
  println( "Frame Rate: " + frameRate );  
} // end debugPrint()



/** ---------------------------------------------------------------------------------
 * indexToX() takes in int index, which is the representational data of a point on
 * the image's array of pixels, and converts it to an X-coordinate
 * ----------------------------------------------------------------------------------
 */
int indexToX(int index) {
  
  return index % WIDTH;

} // end indexToY()



/** ---------------------------------------------------------------------------------
 * indexToY() takes in int index, which is the representational data of a point on
 * the image's array of pixels, and converts it to an Y-coordinate
 * ----------------------------------------------------------------------------------
 */
int indexToY(int index) {

  return (index - (index % WIDTH)) / WIDTH;

} // end indexToY()



/** ---------------------------------------------------------------------------------
 * compareFrames() takes the current image and compares it to the previous image and
 * fills the framePixels array with information if there is movement. The element in
 * framePixels will have either 0 (indicating black) or 1 (indicating white); white will
 * indicate movement.
 * ----------------------------------------------------------------------------------
 */
void compareFrames(){  
  // save previous frame for motion detection
  // before we read the new frame, we always save the previous frame for comparison
  prevFrame = currFrame;
  prevFrame.resize(800,0);
  currFrame = loadImage(streamImg, "jpg");
  currFrame.resize(800,0);
  
  currFrame.loadPixels();
  prevFrame.loadPixels();
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < WIDTH; x++ ) {
    for (int y = 0; y < HEIGHT; y++ ) {
      
      int loc = x + y*WIDTH;                     // 1D pixel location
      
      color currPix = currFrame.pixels[loc];     // the current color
      color prevPix = prevFrame.pixels[loc];     // the previous color
      
      // compare colors (previous vs. current)
      float r1 = red(currPix);   float g1 = green(currPix);   float b1 = blue(currPix);
      float r2 = red(prevPix);   float g2 = green(prevPix);   float b2 = blue(prevPix);
      float diff = dist(r1,g1,b1,r2,g2,b2);
      
      // fills rValues, gValues, bValues arrays with CURRENT rgb values
      rValues[loc] = r1;
      gValues[loc] = g1;
      bValues[loc] = b1;
      
      // if the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) {  // if motion, store color pixel
        framePixels[loc] = WHITE;        
        colorPixels[loc] = currPix;
      }
      else {                   // If not, display black
        framePixels[loc] = BLACK;
        colorPixels[loc] = -1;
      }
      
    } // end y-traverse
  } // end x-traverse
  
} // end compareFrames()


/** ---------------------------------------------------------------------------------
 * drawBackground() draws the background frame.
 * ----------------------------------------------------------------------------------
 */
void drawBackground(){  
  tint(180, 180, 180, 50);

  // draw background
  image(bgFrame, 0, 0);
    
} // end drawBackground()



/** ---------------------------------------------------------------------------------
 * changeBackground() changes the bgFrame after 15 seconds...
 * ----------------------------------------------------------------------------------
 */
void changeBackground(){
  if( frameChange == 60 ){
    if( bgCounter > 19 ){
      bgCounter = 0;  // reset
      println("second = " + (int)second() + "bgCounter = " + bgCounter);
    }
    else{
      bgCounter++;    // increment
      println("second = " + (int)second() + "bgCounter = " + bgCounter);
    }
    
    frameChange = 0;
  }
  
  if     ( bgCounter % 2 == 0 )     bgFrame = bgMain;
  else if( bgCounter == 1 )         bgFrame = bg0;
  else if( bgCounter == 3 )         bgFrame = bg1;
  else if( bgCounter == 5 )         bgFrame = bg2;
  else if( bgCounter == 7 )         bgFrame = bg3;
  else if( bgCounter == 9 )         bgFrame = bg4;
  else if( bgCounter == 11 )        bgFrame = bg5;
  else if( bgCounter == 13 )        bgFrame = bg6;
  else if( bgCounter == 15 )        bgFrame = bg7;
  else if( bgCounter == 17 )        bgFrame = bg8;
  else if( bgCounter == 19 )        bgFrame = bg9;    
  
  frameChange++;
  
} // end changeBackground()



/** ---------------------------------------------------------------------------------
 * drawCanvas() draws the current canvas based on the pixel data found in framePixels.
 * If framePixels contain certain location, there is movement. It clears at the end of this
 * method.
 * ----------------------------------------------------------------------------------
 */
void drawCanvas(){    
  for (int loc = 0; loc < framePixels.length; loc++) {

    int x = indexToX(loc);        // gets x-value
    int y = indexToY(loc);        // gets y-value
    
    // draws people innards
    if(framePixels[loc] == WHITE && isNotNoise(loc, x, y)) {
      color currColor = colorPixels[loc]; // color pixel at loc
            
      fill(red(currColor), green(currColor), blue(currColor));
      rect(x, y , 1, 1);
    }
    
    // draws gray outline
    if(framePixels[loc] == WHITE && !isNotNoise(loc, x, y) ) {
      fill(200);
      rect(x, y, 1, 1);
    }
    
  } // end i-traverse
      
} // end drawCanvas()



/** ---------------------------------------------------------------------------------
 * isNotNoise() is a boolean method that informs us whether or not a certain
 * pixel at coordinate (loc, x, y) is just noise. "Noise" is defined as when it is
 * a lone white pixel in a sea of black.
 * ----------------------------------------------------------------------------------
 */
 
boolean isNotNoise(int loc, int x, int y){
  // boolean set to true if those pixels are white
  boolean leftPix    = false;
  boolean rightPix   = false;
  boolean topPix     = false;
  boolean botPix     = false;

  
  // check pixel on left
  if ( x > 0) {
    if ( framePixels[loc - 1] == WHITE ){
      leftPix = true;
    }
  }
  
  // check pixel on right
  if ( x < WIDTH - 1) {
    if ( framePixels[loc + 1] == WHITE ){
      rightPix = true;
    }
  }

  // check pixel on top
  if ( y > 0) {
    if ( framePixels[loc - WIDTH] == WHITE ){
      topPix = true;
    }
  }  
  
  // check pixel on top
  if ( y < HEIGHT - 1) {
    if ( framePixels[loc + WIDTH] == WHITE ){
      botPix = true;
    }
  }
    
  // return true if all is true
  if (leftPix && rightPix && topPix && botPix) return true;
  else return false;
  
  
} // end isNotNoise()




