import controlP5.*;

ControlP5 cp5;
PImage baseimg;     // base image that is transformed

PWindow win;        // This class used only if GUI is spearate window
Accordion accordion;
int   imgTopLeftCorner_X;  // computed based on GUI is part of sketch window and size of scaled img
float guiXscale,  guiYscale;

color c = color(0, 160, 100);  // not related to program, can be removed
CheckBox emitterCheckbox, displayCheckbox;
RadioButton playpauseRadio, showhideRadio;

//variables to input from screen a start & end points (x,y) of a box from user to bound a emitter or particle system
float new_box_startx, new_box_starty, new_box_endx, new_box_endy; 
boolean drawBoxStart = false;

// if user clicks mouse to select a center of a square box to bound an emitter or particle system then used below as as length of square box
float emitter_squarewall_len;

boolean display_points = true;
boolean display_lines = true;


public void settings() {
  size(displayWidth-reduceFullScreenBy, displayHeight-reduceFullScreenBy);
  guiXscale = GUIWidth/300;
  guiYscale = height/1000.0;
  labelsize = (int) max(8.0,(guiYscale * labelsize));
}

void setup() {
  
  noStroke();
  frameRate(30);
  
  if (!SEPARATE_GUI_WINDOW){
      cp5 = new ControlP5(this);
      setupGUIControls(this);
  }
  else {
       win = new PWindow(this);
  }
  
  hint(DISABLE_DEPTH_MASK);
  
  //to avoid debugging an issue seen intermittently with Widows file selector
  if (loadHardcodedImage){
    //baseimg = loadImage("C:\\Users\\rajrupa\\Desktop\\vangoghpainting.jpg");
    baseimg = loadImage("C:\\Users\\rajrupa\\Desktop\\chess-board-black-and-white.jpg");
    
    OperationsAfterBaseImageLoaded();
  }
}

//Function needed to paint GUI background in draw() ONLY IF GUI is part of sketch window
void drawGUIBackground(){
  noStroke();
  fill(0);
  rect(0,0, GUIWidth, height);
}



void setupGUIControls (PApplet parent) {
  
    PFont GUIfont = createFont ("verdana", labelsize,false);
    ControlFont font1 = new ControlFont(GUIfont,labelsize);
       //<>//
    Group g1 = cp5.addGroup("Image Knobs")
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(170*guiYscale))
                  ;
        
    cp5.addBang("LoadNewImage")
       .setPosition((int)(10*guiXscale),(int)(20*guiYscale))
       .setSize((int)(40*guiXscale),(int)(40*guiYscale))
       //.setFont(font1)
       .setLabel("LOADIMAGE")
       .moveTo(g1)
       .plugTo(parent,"LoadNewImage")
       ;
  
      showhideRadio = cp5.addRadioButton("hideimage")
       .setPosition((int)(10*guiXscale),(int)(95*guiYscale))
       .setItemWidth((int)(40*guiXscale))
       .setItemHeight((int)(40*guiYscale))
       //.setFont(font1)
       .addItem("show image", 1)
       .setColorLabel(color(255))
       .activate(0)
       .moveTo(g1)
       ;

     playpauseRadio = cp5.addRadioButton("playpauseradio")
       .setPosition((int)(130*guiXscale),(int)(20*guiYscale))
       .setItemWidth((int)(40*guiXscale))
       .setItemHeight((int)(40*guiYscale))
       //.setFont(font1)
       .addItem("play/pause", 0)
       .setColorLabel(color(255))
       .activate(0)
       .moveTo(g1)
       ;   

    cp5.addSlider("framerate")
       .setPosition((int)(130*guiXscale),(int)(110*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(1,60)
       .setValue(30)
       .moveTo(g1)
       .plugTo(parent,"framerate")
       ;

         
    Group g2 = cp5.addGroup("Emitter & Particle System Knobs")
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(300*guiYscale))
                  ;

    cp5.addRadioButton("particle_points_radio")
     .setPosition((int)(10*guiXscale),(int)(20*guiYscale))
     .setItemWidth((int)(30*guiXscale))
     .setItemHeight((int)(30*guiYscale))
     //.setFont(font1)
     .addItem("Emitter", 0)
     .addItem("PointSystem", 1)
     .setColorLabel(color(255))
     .activate(1)
     .moveTo(g2)
     .plugTo(parent,"particle_points_radio")
     ;
     
    cp5.addBang("reset")
     .setPosition((int)(130*guiXscale),(int)(20*guiYscale))
     .setSize((int)(40*guiXscale),(int)(40*guiYscale))
     //.setFont(font1)
     .setLabel("Reset")
     .moveTo(g2)
     .plugTo(parent,"resetSystems")
     ;
     
    displayCheckbox = cp5.addCheckBox("displaycheckBox")
      .setPosition((int)(10*guiXscale), (int)(100*guiYscale))
      .setSize((int)(40*guiXscale), (int)(40*guiYscale))
      .setItemsPerRow(2)
      .setSpacingColumn((int)(80*guiXscale))
      .setSpacingRow((int)(25*guiYscale))
      .addItem("Display Points", 1)
      .addItem("Display Lines", 1)
      .moveTo(g2)
      ;
    displayCheckbox.activateAll();
    
    cp5.addSlider("Max Acceleration")
     .setPosition((int)(10*guiXscale),(int)(160*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setRange(0.0,4.0)
     .setValue(2.0)
     .moveTo(g2)
    ;
    
   cp5.addSlider("Friction Coeff")
     .setPosition((int)(10*guiXscale),(int)(190*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setRange(0.0,1.0)
     .setValue(0.0)
     .moveTo(g2)
    ;            
       
   cp5.addSlider("AttractRepelRadius")
     .setPosition((int)(10*guiXscale),(int)(220*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setLabel("Attraction Radius")
     .setRange(0.0, 200.0)
     .setValue(10.0)
     .moveTo(g2)
    ;                      
             
    cp5.addSlider("numParticles")
       .setPosition((int)(10*guiXscale),(int)(250*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(10,10000)
       .setValue(100)
       .moveTo(g2)
       ;             
    Group g3 = cp5.addGroup("Force Knobs")
                  .setFont(font1)
                  .setBackgroundColor(color(0, 64))
                  .setBackgroundHeight((int)(150*guiYscale))
                  ;
       
    emitterCheckbox = cp5.addCheckBox("checkBox")
                .setPosition((int)(10*guiXscale), (int)(10*guiYscale))
                .setSize((int)(40*guiXscale), (int)(40*guiYscale))
                .setItemsPerRow(2)
                .setSpacingColumn(80)
                .setSpacingRow((int)(25*guiYscale))
                .addItem("Brownian Motion", 0)
                .addItem("Attract Repel", 1)
                .addItem("Fairing (tbd)",2)
                .moveTo(g3)
                ;
               
    // group number 3, Emitter
    Group g4 = cp5.addGroup("Emitter Specific Knobs")
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(150*guiYscale))
                  ;
                  
       
     cp5.addSlider("lifespan")
       .setPosition((int)(10*guiXscale),(int)(20*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(10,255)
       .setValue(25)
       .moveTo(g4)
       ;
       
       
       cp5.addSlider("gravity")
       .setPosition((int)(10*guiXscale),(int)(50*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(0,1)
       .setValue(0)
       .moveTo(g4)
       ;
       
       cp5.addSlider("SquareBoxDim")
       .setPosition((int)(10*guiXscale),(int)(80*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(50, 1000)
       .setValue(50)
       .moveTo(g4)
       ;
       

    /*Group g5 = cp5.addGroup("Point System Controls")
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(300*guiYscale))
                  ;
    */                 
    // create a new accordion
    // add g1, g2, and g3 to the accordion.
    accordion = cp5.addAccordion("acc")
                   .setPosition(0,0)
                   .setWidth((int)GUIWidth)
                   .addItem(g1)
                   .addItem(g2)
                   .addItem(g3)
                   .addItem(g4)
                   //.addItem(g5)
                   ;
                   
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);GUIWidth=300;}}, '1');
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2'); 
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
    cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');
    
    accordion.open(0,1,2,3);
    
    // use Accordion.MULTI to allow multiple group 
    // to be open at a time.
    accordion.setCollapseMode(Accordion.MULTI);
    
    // when in SINGLE mode, only 1 accordion  
    // group can be open at a time.  
    // accordion.setCollapseMode(Accordion.SINGLE);

}
  

void particle_points_radio(int theC) { 
  switch(theC) {
    case(0): createPointSystem = false;
             createParticleSystem = true;
             print("emitter mode");
             break;
    case(1): createPointSystem = true;
             createParticleSystem = false;
             print("pointSystems mode");
             break;
  }
} 

void shuffle() {
  c = color(random(255),random(255),random(255),random(128,255));
}

void LoadNewImage() {
  selectInput("Select a file to process:", "fileSelected");
}

void saveTransform() {
  selectInput("Select a file to process:", "fileSelected");
}


void framerate (){
  frameRate((int) cp5.getController("framerate").getValue());
  println("framerate " + frameRate);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } 
  else {
    println("User selected " + selection.getAbsolutePath());
    baseimg = loadImage(selection.getAbsolutePath());
    OperationsAfterBaseImageLoaded();
  }
}
    
    
void OperationsAfterBaseImageLoaded(){
   //Now determine image size to be rendered based on display area vs actual image size
   // check if the scale on width or height is less than 1.0, pick the minimum to scale
    
    float widthScaleFactor, heightScaleFactor, guiwidth=0.0;
    
    if (!SEPARATE_GUI_WINDOW) guiwidth = GUIWidth; //take out GUI width from skectch area

    heightScaleFactor = (float) height/ (float)baseimg.height;
    widthScaleFactor  = (float)(width-guiwidth)/ (float) baseimg.width;
    
    float scaleFactor = min (heightScaleFactor, widthScaleFactor, 1.0);

    int   imgWidth,imgHeight;  // computed by the scaled image dimensions of loaded image

    imgWidth = (int) (scaleFactor * baseimg.width - 1)  ;
    imgHeight = (int) (scaleFactor * baseimg.height -1) ;
    
    baseimg.resize(imgWidth, imgHeight);
    
    imgTopLeftCorner_X = (int) (guiwidth + (width - guiwidth - baseimg.width)/2);
    
    
    //println("baseimg.width = " + baseimg.width + ", baseimg.height = " + baseimg.height);
    
    //Update adjpixel_values[][][8] array
    adjPixelsDerivatives =  new float[baseimg.width][baseimg.height][8];
    compute_PartialDerivativesOfPixelWRTAdjacentPixels();
}


void controlEvent(ControlEvent theEvent) {
  
  if (theEvent.isFrom(emitterCheckbox)) {
  
    for (int i=0;i<emitterCheckbox.getArrayValue().length;i++) {
      int n = (int)emitterCheckbox.getArrayValue()[i];
      
      switch (i) {
            case 0:  if (n==1) has_brownianmotion = true;
                     else has_brownianmotion = false;
                     println ("Brownian Motion set to " + has_brownianmotion);
                     break;
            case 1:  
                     if (n==1) has_attractionrepulsion = true;
                     else has_attractionrepulsion = false;
                     println ("Attraction Repel set to " + has_attractionrepulsion);
                     break;
            case 4:  
                     break;
            case 5:  
                     break;
            case 6:  
                     break; 

      }
    }
  }
 
  else if (theEvent.isFrom((Slider) cp5.getController("numParticles"))) { 
        numParticles = (int) cp5.getController("numParticles").getValue();
        println ("changing numParticles event:" + numParticles);

        if (baseimg != null){
          for (ParticleSystem ps: systems)
          {
              ps.change_num_of_particles(numParticles);
          }
        }
  }
  else if (theEvent.isFrom((Slider) cp5.getController("lifespan"))) { 
        lifespan = (int) cp5.getController("lifespan").getValue();
        println ("changing lifespan event:" + lifespan);
        
        for (ParticleSystem ps: systems)
        {
            ps.updateLifeSpan(lifespan);
        }
  }
  else if (theEvent.isFrom((Slider) cp5.getController("Max Acceleration"))) { 
        max_acceleration = (float) cp5.getController("Max Acceleration").getValue();
        println ("Acceleration:" + max_acceleration);
  }
  
  else if (theEvent.isFrom((Slider) cp5.getController("Friction Coeff"))) { 
        coeff_friction = (float) cp5.getController("Friction Coeff").getValue();
        println ("Friction Coeff:" + coeff_friction);
  }
  
  else if (theEvent.isFrom((Slider) cp5.getController("AttractRepelRadius"))) { 
        D_attraction = (float) cp5.getController("AttractRepelRadius").getValue();
        D_repulsion = D_attraction/4.0;
        println ("AttractRepelRadius:" + D_attraction);
        //for(PointSystem ps:  spirals) ps.intitalizeGridSystem();
  }
  else if (theEvent.isFrom((Slider) cp5.getController("SquareBoxDim"))) {
        emitter_squarewall_len = (int) cp5.getController("SquareBoxDim").getValue();
        println ("changing emitter square len to:" + emitter_squarewall_len);

  }
  else if (theEvent.isFrom(displayCheckbox)) {
    for (int i=0;i<displayCheckbox.getArrayValue().length;i++) {
      int n = (int)displayCheckbox.getArrayValue()[i];
      
      switch (i) {
            case 0:  if (n==1) display_points = true;
                      else display_points = false;
                    break;  
            case 1:  if (n==1) display_lines = true;
                    else display_lines = false;
                    break;
      }
    }
  }
  else if (theEvent.isFrom(showhideRadio)) {
      println("showhide radio control:" + showhideRadio.getItem(0).getState());
    
    if ( showhideRadio.getItem(0).getState()) {
      showImage = true;
      println("show");

    }
    else {
      showImage = false;
      println("hide");
    }
  }
  else if (theEvent.isFrom((playpauseRadio))) {
    println("playpause radio control:" + playpauseRadio.getItem(0).getState());
    
    if ( playpauseRadio.getItem(0).getState()) {
      loop();
      println("play");
      //playpauseRadio.getItem(0).setImage(buttonimgs[1]);

    }
    else {
      noLoop();
      println("pause");
      //playpauseRadio.getItem(0).setImage(buttonimgs[0]);

   }
  } 
}

//need a reset method, reset resets systems
void resetSystems()
{
    //make sure to do deep cleaning
    systems.clear();
    spirals.clear();
    println("reset");

}

// This class used only if GUI is SEPARATE WINDOW
class PWindow extends PApplet {
  PApplet parent;
  
  PWindow(PApplet app) {
    super();
    parent = app;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
    
    cp5 = new ControlP5(this);

    setupGUIControls(parent); //pass the original sketch to GUI code
  }
  void settings() {
    size(GUIWidth, parent.height);
  }
 
  void setup() {
     delay(1000); // this 1 sec delay seems to workaround a concurrent execution issue when separate GUI window is used
  }
 
  void draw() {
    background(0);
  }
}



void mousePressed(){
  
  // When mouse is pressed over image, its start corner of a box. 
  // When mouse released its the diagonal opposite corner

  if(baseimg != null) {
    if (OverImage(mouseX, mouseY)){
         println("mouse pressed");

          drawBoxStart = true;
          new_box_startx = mouseX;
          new_box_starty = mouseY;
     }
     else drawBoxStart = false;
  }
}
 

void mouseReleased(){
   
  // When mouse is pressed over image, its start corner of a box. 
  // When mouse released its the diagonal opposite corner
  
  if(drawBoxStart && OverImage(mouseX, mouseY))
  {
     new_box_endx = mouseX;
     new_box_endy = mouseY;
           println("mouse released");

     
     //normalize to left top corner and right bottom corner, user may have picked left bottom and right top 
     if (new_box_endx < new_box_startx){
       float temp = new_box_endx;
       new_box_endx = new_box_startx;
       new_box_startx = temp;
     }
     if (new_box_endy < new_box_starty){
       float temp = new_box_endy;
       new_box_endy = new_box_starty;
       new_box_starty = temp;
     }
     
     if (((new_box_endx - new_box_startx) <= 2) && (new_box_endy - new_box_starty) <= 2){
       //the bounding box is really small - user wanted to click in single place - treat as mouseclicked in place
       
        if(createParticleSystem)
        {
            systems.add(new ParticleSystem(numParticles, lifespan, 
                          mouseX - (emitter_squarewall_len/2), 
                          mouseY - (emitter_squarewall_len/2), 
                          mouseX + (emitter_squarewall_len/2), 
                          mouseY + (emitter_squarewall_len/2)));
        }
        if(createPointSystem)
        {
           PointSystem s = new PointSystem(imgTopLeftCorner_X, 0, imgTopLeftCorner_X + 
                               baseimg.width, baseimg.height); 
           spirals.add(s); 
        }
       
     }
     else { //user intent is to create a bounding box by pressing mouse and dragging and then releasing vs clicking in one spot
       if(createParticleSystem)
        {
            systems.add(new ParticleSystem(numParticles, lifespan, 
                                           new_box_startx, new_box_starty, 
                                           new_box_endx, new_box_endy));
        }
        else if(createPointSystem)
        {
           
           PointSystem s = new PointSystem(new_box_startx, new_box_starty, 
                                 new_box_endx, new_box_endy); 
           spirals.add(s); 
           
        }
     }
  }
  drawBoxStart = false;

}

  //Is a particle(x, y) located in the 
  //particle emitter region with center (center_x, center_y)
  
  boolean OverImage(float x, float y)
  {
      if(x >= imgTopLeftCorner_X &&
         x <= imgTopLeftCorner_X + baseimg.width &&
         y >=0 &&
         y <=  baseimg.height){
          return true;     
      }
      return false;
  }
  
  
  
int convertToGrayScale(color c)
{
    int r=(c&0x00FF0000)>>16; // red part
    int g=(c&0x0000FF00)>>8; // green part
    int b=(c&0x000000FF); // blue part
    int grey=(r+b+g)/3;
    return grey;
}

//compute the partial derivatives for a pixel location (i, j)
//p = pixels[i][j] where i corresponds to row and j corresponds to column
 
void compute_PartialDerivativesOfPixelWRTAdjacentPixels()
{
  
  //for boundary pixels on image, set to white, high color values
  //check i = 0, i  = baseimg.width - 1, j = 0, j = baseimg.height - 1
  
  int i, j;
  
  //set partial derivatives of adjacent neighbors of corner pixels of image to 0 and diagonal neighbors to -BIG_NUM 
  
  adjPixelsDerivatives[0][0][6] = adjPixelsDerivatives[0][0][0] = 0; //topLeft
  adjPixelsDerivatives[0][0][5] = - BIG_NUM;
  adjPixelsDerivatives[0][baseimg.height - 1][0] = adjPixelsDerivatives[0][baseimg.height - 1][2] = 0; //bottomLeft
  adjPixelsDerivatives[0][baseimg.height - 1][7] = -BIG_NUM;
  adjPixelsDerivatives[baseimg.width - 1][0][1] = adjPixelsDerivatives[baseimg.width - 1][0][6] = 0; //topRight
  adjPixelsDerivatives[baseimg.width - 1][0][3] = -BIG_NUM;
  adjPixelsDerivatives[baseimg.width - 1][baseimg.height - 1][1] = adjPixelsDerivatives[baseimg.width - 1][baseimg.height - 1][2] = 0; //bottomRight
  adjPixelsDerivatives[baseimg.width - 1][baseimg.height - 1][5] = -BIG_NUM;

  
  i = 0;
  
  for(j = 1; j < baseimg.height - 1; j++) 
  {
      //go through first column of pixels in image
      
      
      adjPixelsDerivatives[0][j][2] = adjPixelsDerivatives[0][j][6] = 0; //set derivatives of adjacent pixels along boundary to 0(3rd and 7th neighborPixel)
      //      
      adjPixelsDerivatives[0][j][1] = adjPixelsDerivatives[0][j][4] = adjPixelsDerivatives[0][j][7] = -BIG_NUM; //set derivatives of 2nd, 5th, and 8th neighboring pixels to -BIG_NUM
      //
      adjPixelsDerivatives[1][j][0] = BIG_NUM; //rightPixel has derivative BIG_NUM to adjacent pixel in first column

      
      
      //go through last column of pixels in image
      
      //set derivatives of adjacent pixels along boundary to 0(3rd and 7th neighborPixel)
      adjPixelsDerivatives[baseimg.width - 1][j][2] = adjPixelsDerivatives[baseimg.width - 1][j][6] = 0;
      //set derivatives of 1st, 4th, 6th neighboring pixels to -BIG_NUM 
      adjPixelsDerivatives[baseimg.width - 1][j][0] = adjPixelsDerivatives[baseimg.width - 1][j][3] = adjPixelsDerivatives[baseimg.width - 1][j][5] = -BIG_NUM;
      
      adjPixelsDerivatives[baseimg.width - 2][j][1] = BIG_NUM; //leftPixel has derivate BIG_NUM to adjacent pixel in last column
  }
  
  j = 0;
  
  for(i = 1; i < baseimg.width - 1; i++)
  {
      //go through first row of pixels in image
    
      //set derivatives of adjacent pixels along boundary to 0(6th and 8th neighborPixel)
      adjPixelsDerivatives[i][0][5] = adjPixelsDerivatives[i][0][7] = 0;
      //set derivatives of 3rd, 4th, and 5th neighboring pixels to -BIG_NUM
      adjPixelsDerivatives[i][0][2] = adjPixelsDerivatives[i][0][3] = adjPixelsDerivatives[i][0][4] = -BIG_NUM;
      //
      adjPixelsDerivatives[i][1][6] = BIG_NUM; //set derivative of 7th neighbor pixel to BIG_NUM
      
      //go through last row of pixels in image
    
      //set derivatives of adjacent pixels along boundary to 0(1st and 2nd neighborPixel)
      adjPixelsDerivatives[i][baseimg.height - 1][0] = adjPixelsDerivatives[i][0][1] = 0;
      //set derivatives of 6th, 7th, and 8th neighboring pixels to -BIG_NUM
      adjPixelsDerivatives[i][baseimg.height - 1][5] = adjPixelsDerivatives[i][0][6] = adjPixelsDerivatives[i][0][7] = -BIG_NUM;
      //
      adjPixelsDerivatives[i][baseimg.height - 2][2] = BIG_NUM; //set derivative of 3rd neighbor pixel to BIG_NUM
  }
  
  
  
  for (i = 1; i < baseimg.width - 1; i++){
    for (j = 1; j < baseimg.height - 1; j++){

          
          color c = baseimg.get(i, j);
          color c1 = baseimg.get(i, j-1); 
          color c2 = baseimg.get(i, j+1); 
          color c3 = baseimg.get(i+1, j);  
          color c4 = baseimg.get(i+1, j-1);//corner
          color c5 = baseimg.get(i+1, j+1);//corner
          color c6 = baseimg.get(i-1, j-1);//corner
          color c7 = baseimg.get(i-1, j);
          color c8 = baseimg.get(i-1, j+1);//corner
          
          float grey = convertToGrayScale(c);
          float grey1 = convertToGrayScale(c1);
          float grey2 = convertToGrayScale(c2);
          float grey3 = convertToGrayScale(c3);
          float grey4 = convertToGrayScale(c4);
          float grey5 = convertToGrayScale(c5);
          float grey6 = convertToGrayScale(c6);
          float grey7 = convertToGrayScale(c7);
          float grey8 = convertToGrayScale(c8);
          
          
          adjPixelsDerivatives[i][j][0] = (grey1 - grey) / 1.0;
          adjPixelsDerivatives[i][j][1] = (grey2 - grey) / 1.0;
          adjPixelsDerivatives[i][j][2] = (grey3 - grey) / 1.0;
          adjPixelsDerivatives[i][j][3] = (grey4 - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][4] = (grey5 - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][5] = (grey6 - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][6] = (grey7 - grey) / 1.0;
          adjPixelsDerivatives[i][j][7]  = (grey8 - grey) / sqrt(2);//corner
          
          
          //changing values
          
          /*
          
          float grey = convertToGrayScale(baseimg.get(i, j));
          
          adjPixelsDerivatives[i][j][0] = (convertToGrayScale(baseimg.get(i, j - 1)) - grey) / 1.0;
          adjPixelsDerivatives[i][j][1] = (convertToGrayScale(baseimg.get(i, j + 1)) - grey) / 1.0;
          adjPixelsDerivatives[i][j][2] = (convertToGrayScale(baseimg.get(i + 1, j)) - grey) / 1.0;
          adjPixelsDerivatives[i][j][3] = (convertToGrayScale(baseimg.get(i + 1, j - 1)) - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][4] = (convertToGrayScale(baseimg.get(i + 1, j + 1)) - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][5] = (convertToGrayScale(baseimg.get(i - 1, j - 1)) - grey) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][6] = (convertToGrayScale(baseimg.get(i - 1, j)) - grey) / 1.0;
          adjPixelsDerivatives[i][j][7] = (convertToGrayScale(baseimg.get(i - 1, j + 1)) - grey) / sqrt(2);//corner
         
          */
    }
  }
}

//not using compute_gradient

/*//compute gradient between two points 
float compute_gradient(Point p1, Point p2)
{
    float displacement_X = p2.x - p1.x;
    float displacement_Y = p2.y - p1.y;
    
    color c1 = baseimg.get((int)(p1.x), (int)(p1.y));
    color c2 = baseimg.get((int)(p2.x), (int)(p2.y));
    
    float z1 = convertToGrayScale(c1);
    float z2 = convertToGrayScale(c2);
    
    //println("z1 = " + z1 + ", z2 = " + z2);
    
    float run = sqrt(displacement_X * displacement_X + displacement_Y * displacement_Y);
    float rise = z2 - z1;
    float slope = rise / run;
    return slope;
}


//not using precompute_density

/*

//iterate through pixelArray of baseimg and precompute gradients Array
//i corresponds to row, j corresponds to column

void precompute_pointDensity()
{
    float[][] gradientArray = new float[baseimg.height][baseimg.width];
    float[][] pointDensity = new float[baseimg.height][baseimg.width];
    
    for(int i = 0; i < baseimg.height; i++)
    {
        for(int j = 0; j < baseimg.width; j++)
        {
             gradientArray[i][j] = compute_gradient_pixel(i, j);
             
             if(i != 0) pointDensity[i][j] = pointDensity[i-1][j] +
             compute_partialderivative_X(i, j);
             else if(j != 0) pointDensity[i][j] = pointDensity[i][j - 1] + 
             compute_partialderivative_Y(i, j);
             else pointDensity[i][j] = 30;//(i, j) is (0, 0)
             
        }
    }
    
}

*/
