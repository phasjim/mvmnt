// MVMNT
// BY PRITA PRISCILLA HASJIM

import java.util.*;

PImage currFrame;      // current frame we are looking at
PImage prevFrame;      // previous frame that we are looking at

int WIDTH = 0;
int HEIGHT = 0;

final float threshold = 30;  // threshold number to indicate change between frams

final int BLACK = 0;
final int WHITE = 1;
final int TOTALPIXELS = 1024000;

int[] framePixels = new int[TOTALPIXELS]; // framePixels will contain
                                          // the black (0) and white (1)
                                          // pixel data that shows change

float[] rValues = new float[TOTALPIXELS]; // all current r-values
float[] gValues = new float[TOTALPIXELS]; // all current g-values
float[] bValues = new float[TOTALPIXELS]; // all current b-values

// stream image
String streamImg = "http://132.239.12.145/axis-cgi/jpg/image.cgi?resolution=640x400";



/** ---------------------------------------------------------------------------------
 * setup() does the default settings for the frame
 * ----------------------------------------------------------------------------------
 */
void setup() {
  size(1280, 800);       // sets the size
  background(50);        // sets background
  noStroke();            // sets no stroke
  
  currFrame = loadImage(streamImg, "jpg");
  currFrame.resize(1280,0);
  
  // sets up these global variables
  WIDTH = currFrame.width;
  HEIGHT = currFrame.height;
  
  fill(0);
  rect(0, 0, 1280, 800);
  
} // end setup()



/** ---------------------------------------------------------------------------------
 * draw() is the main method
 * ----------------------------------------------------------------------------------
 */
void draw() {
  // debug statements
  // debugPrint();
  
  compareFrames();
  drawCanvas();
  
} // end draw()



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
  prevFrame.resize(1280,0);
  currFrame = loadImage(streamImg, "jpg");
  currFrame.resize(1280,0);
  
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
      if (diff > threshold) {  // if motion, display white
        framePixels[loc] = WHITE;
      }
      else {                   // If not, display black
        framePixels[loc] = BLACK;
      }
      
    } // end y-traverse
  } // end x-traverse
  
} // end compareFrames()



/** ---------------------------------------------------------------------------------
 * drawCanvas() draws the current canvas based on the pixel data found in framePixels.
 * 1 (white) will indicate movement; otherwise 0 (black) will indicate no movement.
 * ----------------------------------------------------------------------------------
 */
void drawCanvas(){
  fill(0, 90);
  rect(0, 0, 1280, 800);
  
  for (int i = 0; i < framePixels.length; i++) {
    
    int x = indexToX(i);        // gets x-value
    int y = indexToY(i);        // gets y-value
    
    if(framePixels[i] == WHITE && !isNotNoise(i, x, y) ) {
      fill(255);
      rect(x, y, 1, 1);
    }
    
  } // end i-traverse
  
} // end drawCanvas()



/** ---------------------------------------------------------------------------------
 * isNotNoise() is a boolean method that informs us whether or not a certain
 * pixel at coordinate (i, x, y) is just noise. "Noise" is defined as when it is
 * a lone white pixel in a sea of black.
 * ----------------------------------------------------------------------------------
 */
boolean isNotNoise(int i, int x, int y){
  // boolean set to true if those pixels are white
  boolean leftPix    = false;
  boolean rightPix   = false;
  boolean topPix     = false;
  boolean botPix     = false;

  
  // check pixel on left
  if ( x > 0) {
    if ( framePixels[i - 1] == WHITE ){
      leftPix = true;
    }
  }
  
  // check pixel on right
  if ( x < WIDTH - 1) {
    if ( framePixels[i + 1] == WHITE ){
      rightPix = true;
    }
  }

  // check pixel on top
  if ( y > 0) {
    if ( framePixels[i - WIDTH] == WHITE ){
      topPix = true;
    }
  }  
  
  // check pixel on top
  if ( y < HEIGHT - 1) {
    if ( framePixels[i + WIDTH] == WHITE ){
      botPix = true;
    }
  }
    
  // return true if all is true
  if (leftPix && rightPix && topPix && botPix) return true;
  else return false;
  
  
} // end isNotNoise()




