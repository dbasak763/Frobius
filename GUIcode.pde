import controlP5.*;

ControlP5 cp5;
PImage baseimg;     // base image that is transformed

Accordion accordion;
int   imgTopLeftCorner_X;  // computed based on GUI is part of sketch window and size of scaled img
float guiXscale,  guiYscale;

color c = color(0, 160, 100);  // not related to program, can be removed
CheckBox forceCheckBox, displayCheckbox;
RadioButton playpauseRadio, showhideRadio, particlePointRadio;
Textlabel myTextlabelA, myTextlabelB;

//variables to input from screen a start & end points (x,y) of a box from user to bound a emitter or particle system
float new_box_startx, new_box_starty, new_box_endx, new_box_endy; 
boolean drawBoxStart = false;

// if user clicks mouse to select a center of a square box to bound an emitter or particle system then used below as as length of square box
float emitter_squarewall_len;

boolean display_points = true;
boolean display_lines = true;

boolean printpixelgradients = true;


public void settings() {
  size(displayWidth-reduceFullScreenBy, displayHeight-reduceFullScreenBy);
  guiXscale = GUIWidth/300;
  guiYscale = height/1000.0;
  labelsize = (int) max(8.0,(guiYscale * labelsize));
}

void setup() {
  
  noStroke();
  frameRate(30);
  
  //ps = new PointSystem(500, 500, 800, 800);
  
  cp5 = new ControlP5(this);
  setupGUIControls(this);
  

  hint(DISABLE_DEPTH_MASK);
  
  //to avoid debugging an issue seen intermittently with Widows file selector
  if (loadHardcodedImage){
    baseimg = loadImage(hardCodedImageFile);
    
    OperationsAfterBaseImageLoaded();
  }
}

//Function needed to paint GUI background in draw() ONLY IF GUI is part of sketch window
void drawGUIBackground(){
  noStroke();
  fill(0);
  rect(0,0, GUIWidth, height);
}


//cp5 widgets
void setupGUIControls (PApplet parent) {
  
    PFont GUIfont = createFont ("verdana", labelsize,false);
    ControlFont font1 = new ControlFont(GUIfont,labelsize);
       //<>//
    Group g1 = cp5.addGroup("Image Knobs") //<>//
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(170*guiYscale)) //<>//
                  ;
        
    cp5.addBang("LoadNewImage")
       .setPosition((int)(10*guiXscale),(int)(20*guiYscale))
       .setSize((int)(40*guiXscale),(int)(40*guiYscale))
       //.setFont(font1)
       .setLabel("LOADIMAGE")
       .moveTo(g1)
       .plugTo(parent,"LoadNewImage")
       ;
  
      showhideRadio = cp5.addRadioButton("showhideimageradio")
       .setPosition((int)(10*guiXscale),(int)(95*guiYscale))
       .setItemWidth((int)(40*guiXscale))
       .setItemHeight((int)(40*guiYscale))
       //.setFont(font1)
       .addItem("show image", 1)
       .setColorLabel(color(255))
       .activate(0)
       .moveTo(g1)
       .plugTo(parent,"showhideimageradio")
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
       .plugTo(parent, "playpauseradio");
       ;   

    cp5.addSlider("myframerate")
       .setPosition((int)(130*guiXscale),(int)(110*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setLabel("FrameRate")
       .setRange(1,60)
       .setValue(30)
       .moveTo(g1)
       //.plugTo(parent,"framerate")
       .plugTo(parent,"controlEvent")
       ;
       
    myTextlabelA = cp5.addTextlabel("label")
        .setText("FrameCount " + frameCount)
        .setPosition((int)(130*guiXscale),(int)(140*guiYscale))
        //.setColorValue(0xffffff00)
        //.setFont(createFont("Georgia",20))
        .moveTo(g1);
      ;
       
    cp5.addFrameRate().setInterval(10).setPosition((int)(130*guiXscale),(int)(95*guiYscale)).moveTo(g1);
         
    Group g2 = cp5.addGroup("Emitter & Particle System Knobs")
                  .setBackgroundColor(color(0, 64))
                  .setFont(font1)
                  .setBackgroundHeight((int)(250*guiYscale))
                  ;

    particlePointRadio = cp5.addRadioButton("particle_points_radio")
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
     //.plugTo(parent,"controlEvent")
     ;
     
    cp5.addBang("reset")
     .setPosition((int)(130*guiXscale),(int)(20*guiYscale))
     .setSize((int)(40*guiXscale),(int)(40*guiYscale))
     //.setFont(font1)
     .setLabel("Reset")
     .moveTo(g2)
     .plugTo(parent,"resetSystems")
     ;
     
    myTextlabelB = cp5.addTextlabel("label1")
        .setText("Points: ")
        .setPosition((int)(200*guiXscale),(int)(40*guiYscale))
        //.setColorValue(0xffffff00)
        //.setFont(createFont("Georgia",20))
        .moveTo(g2);
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
      .plugTo(parent,"controlEvent")
      ;
    displayCheckbox.activateAll();
   
    cp5.addSlider("DistBetweenPoints")
       .setPosition((int)(10*guiXscale),(int)(160*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setLabel("D_betweenPoints")
       .setRange(10,50)
       .setValue(15)
       .moveTo(g2)
       .plugTo(parent,"controlEvent")
       ;      
      
    
       
   cp5.addSlider("AttractRepelK0")
     .setPosition((int)(10*guiXscale),(int)(190*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setLabel("AR_k0")
     .setRange(0.1, 0.3)
     .setValue(0.1)
     .setNumberOfTickMarks(2)
     .moveTo(g2)
     .plugTo(parent,"controlEvent")

    ;                      
       
       
       
       
    Group g3 = cp5.addGroup("Force Knobs")
                  .setFont(font1)
                  .setBackgroundColor(color(0, 64))
                  .setBackgroundHeight((int)(150*guiYscale))
                  ;
       
    forceCheckBox = cp5.addCheckBox("checkBox")
                .setPosition((int)(10*guiXscale), (int)(10*guiYscale))
                .setSize((int)(40*guiXscale), (int)(40*guiYscale))
                .setItemsPerRow(2)
                .setSpacingColumn(80)
                .setSpacingRow((int)(25*guiYscale))
                .addItem("Brownian Motion", 0)
                .addItem("Attract Repel", 1)
                .addItem("Fairing",2)
                .moveTo(g3)
                .plugTo(parent,"controlEvent")
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
       .plugTo(parent,"controlEvent")
       ;
       
       
       cp5.addSlider("gravity")
       .setPosition((int)(10*guiXscale),(int)(50*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(0,1)
       .setValue(0)
       .moveTo(g4)
       .plugTo(parent,"controlEvent")
       ;
       
       cp5.addSlider("SquareBoxDim")
       .setPosition((int)(10*guiXscale),(int)(80*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setRange(50, 1000)
       .setValue(50)
       .moveTo(g4)
       .plugTo(parent,"controlEvent")

       ;
       
      cp5.addSlider("numParticles")
       .setPosition((int)(10*guiXscale),(int)(110*guiYscale))
       .setSize((int)(100*guiXscale),(int)(20*guiYscale))
       //.setFont(font1)
       .setLabel("Num Particles/Points")
       .setRange(10,10000)
       .setValue(1000)
       .moveTo(g4)
       .plugTo(parent,"controlEvent")
       ;  
       
    cp5.addSlider("Max Acceleration")
     .setPosition((int)(10*guiXscale),(int)(140*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setRange(0.0,4.0)
     .setValue(2.0)
     .moveTo(g4)
     .plugTo(parent,"controlEvent")
    ;       
      
   cp5.addSlider("Friction Coeff")
     .setPosition((int)(10*guiXscale),(int)(170*guiYscale))
     .setSize((int)(100*guiXscale),(int)(20*guiYscale))
     //.setFont(font1)
     .setRange(0.0,1.0)
     .setValue(0.0)
     .moveTo(g4)
     .plugTo(parent,"controlEvent")
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
             println("Set emitter mode");
             break;
    case(1): createPointSystem = true;
             createParticleSystem = false;
             println("Set pointSystems mode");
             break;
  }
}

void showhideimageradio(int theC) { 
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

void playpauseradio(int theC) { 
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


void LoadNewImage() {
  selectInput("Select a file to process:", "fileSelected");
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
    
    guiwidth = GUIWidth; //take out GUI width from skectch area

    heightScaleFactor = (float) height/ (float)baseimg.height;
    widthScaleFactor  = (float)(width-guiwidth)/ (float) baseimg.width;
    
    float scaleFactor = min (heightScaleFactor, widthScaleFactor, 1.0);

    int   imgWidth,imgHeight;  // computed by the scaled image dimensions of loaded image

    imgWidth = (int) (scaleFactor * baseimg.width)  ;
    imgHeight = (int) (scaleFactor * baseimg.height) ;
    
    baseimg.resize(imgWidth, imgHeight);
    
    imgTopLeftCorner_X = (int) (guiwidth + (width - guiwidth - baseimg.width)/2);
    
    
    println("baseimg.width = " + baseimg.width + ", baseimg.height = " + baseimg.height);
    
    computeGrayScaleBaseImagePixels();
    setScalingAndDeltaFunctionsBasedOnBaseImagePixels();
    compute_PartialDerivativesOfBaseImagePixelWRTAdjacentPixels();
}


void controlEvent(ControlEvent theEvent) {
  
  if (theEvent.isFrom(forceCheckBox)) {
  
    for (int i=0;i<forceCheckBox.getArrayValue().length;i++) {
      int n = (int)forceCheckBox.getArrayValue()[i];
      
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
            case 2:  
                     if (n==1) has_fairing = true;
                     else has_fairing = false;
                     println ("Fairing set to " + has_fairing);
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
  else if (theEvent.isFrom((Slider) cp5.getController("DistBetweenPoints"))) { 
        D = (int) cp5.getController("DistBetweenPoints").getValue();
        R0 = D * (float) cp5.getController("AttractRepelK0").getValue(); //D_repulsion = k0*D = sigma in LJ potential function
        R1 = 2.5 * R0;//R1 = k1*D. For now computing as  2.5*sigma as indicated by LJ potential formula;
        for (PointSystem ps: spirals)
        {
            ps.intitalizeGridSystem();
        }
        
        println ("Changing DistBetweenPoints event:" + D + " also changes RepelRadius: " + R0 + " AttractRadius: " + R1);
  }
  else if (theEvent.isFrom((Slider) cp5.getController("myframerate"))) { 
      frameRate((int) cp5.getController("myframerate").getValue());
      println("framerate (set) " + (int) cp5.getController("myframerate").getValue() + " (actual) " + frameRate);
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
  
  else if (theEvent.isFrom((Slider) cp5.getController("AttractRepelK0"))) { 
        R0 = D * (float) cp5.getController("AttractRepelK0").getValue(); //D_repulsion = k0*D = sigma in LJ potential function
        R1 = 2.5 * R0;//R1 = k1*D. For now computing as  2.5*sigma as indicated by LJ potential formula;
        for (PointSystem ps: spirals)
        {
            ps.intitalizeGridSystem();
        }
        println ("RepelRadius: " + R0 + " AttractRadius: " + R1);
  }
  else if (theEvent.isFrom((Slider) cp5.getController("SquareBoxDim"))) {
        emitter_squarewall_len = (int) cp5.getController("SquareBoxDim").getValue();
        println ("changing emitter square len to:" + emitter_squarewall_len);

  }
  else if (theEvent.isFrom((Slider) cp5.getController("gravity"))) {
        gravity = cp5.getController("gravity").getValue();
        println ("changing gravity to:" + gravity);

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
}

//need a reset method, reset resets systems
void resetSystems()
{
    //make sure to do deep cleaning
    systems.clear();
    spirals.clear();
    println("reset");

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
                               baseimg.width-1, baseimg.height-1); 
           spirals.add(s); 
        }
       
     }
     //else user intent is to create a bounding box by pressing mouse and dragging and then releasing vs clicking in one spot
     else if (((new_box_endx - new_box_startx) > 2) && (new_box_endy - new_box_starty) > 2){ 
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
     else {
       // any other case like a very skinny 0 or 1 pixel wide or height rectangle - ignore
     }
     
  }
  drawBoxStart = false;

}

  //Is a particle(x, y) located in the 
  //particle emitter region with center (center_x, center_y)
  
  boolean OverImage(float x, float y)
  {
      if(x >= imgTopLeftCorner_X &&
         x < imgTopLeftCorner_X + baseimg.width &&
         y >=0 &&
         y <  baseimg.height){
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

void computeInertiaOfBaseImage()
{
  
  
}

void computeGrayScaleBaseImagePixels(){
    color c;
    
    grayScaleImage = new float[baseimg.width][baseimg.height];
    
    for (int j = 0; j < baseimg.height; j++){
       for (int i = 0; i < baseimg.width; i++){
         c = baseimg.get(i, j);
         grayScaleImage[i][j] =  convertToGrayScale(c);
       }
    }
}

void setScalingAndDeltaFunctionsBasedOnBaseImagePixels(){
    
    f_a = new float[baseimg.width][baseimg.height];
    f_b = new float[baseimg.width][baseimg.height];
    f_f = new float[baseimg.width][baseimg.height];

    delta = new float[baseimg.width][baseimg.height];
    
    for (int j = 0; j < baseimg.height; j++){
      for (int i = 0; i < baseimg.width; i++){   
          f_b[i][j] = 0.2; //or 0
          f_f[i][j] = 0.3;//or 0.005
          f_a[i][j] = 1; // or 0
          float delta_based_on_grayscale = (grayScaleImage[i][j] + 1) / 256;
          delta_based_on_grayscale = ceil(delta_based_on_grayscale/0.05)/20.0;
          
          delta[i][j] = delta_based_on_grayscale; //1.00 or 0.02

      }
    }              
}

//compute the partial derivatives for a pixel location (i, j)
//p = pixels[i][j] where i corresponds to row and j corresponds to column
 
void compute_PartialDerivativesOfBaseImagePixelWRTAdjacentPixels()
{
          /*  Numbering neighboring pixels around a refernce pixel (i,j)
            i-1  i  i+1
           ------------
           | 5 | 0 | 3 | j-1
           ------------
           | 6 |i,j| 2 |  j
           ------------
           | 7 | 1 | 4 | j+1
        */  
      
  //for boundary pixels on image, set to white, high color values
  //check i = 0, i  = baseimg.width - 1, j = 0, j = baseimg.height - 1
  
  int i, j;
  int BIG_DERIVATIVE = -255;
  
  adjPixelsDerivatives =  new float[baseimg.width][baseimg.height][8];

  
  //go through first and last rows of pixels in image and set as if outside the picture has a steep gradient (negative)
  for(i = 0; i < baseimg.width; i++) 
  {
      /// first  row
      adjPixelsDerivatives[i][0][5] = BIG_DERIVATIVE;
      adjPixelsDerivatives[i][0][0] = BIG_DERIVATIVE;
      adjPixelsDerivatives[i][0][3] = BIG_DERIVATIVE;
      if (i != 0) adjPixelsDerivatives[i][0][6] = BIG_DERIVATIVE; //(grayScaleImage[i-1][0]   - grayScaleImage[i][0]) / 1.0;
      if (i != 0) adjPixelsDerivatives[i][0][7] = -BIG_DERIVATIVE;//(grayScaleImage[i-1][1] - grayScaleImage[i][0]) / sqrt(2);
      if (i != baseimg.width -1) adjPixelsDerivatives[i][0][2] = BIG_DERIVATIVE; //(grayScaleImage[i+1][0]   - grayScaleImage[i][0]) / 1.0;
      if (i != baseimg.width -1) adjPixelsDerivatives[i][0][4] = -BIG_DERIVATIVE;//(grayScaleImage[i+1][1] - grayScaleImage[i][0]) / sqrt(2);//corner
      adjPixelsDerivatives[i][0][1] = -BIG_DERIVATIVE;//(grayScaleImage[i][1]   - grayScaleImage[i][0]) / 1.0;
      
      //last row
      adjPixelsDerivatives[i][baseimg.height - 1][7] = BIG_DERIVATIVE;
      adjPixelsDerivatives[i][baseimg.height - 1][1] = BIG_DERIVATIVE;
      adjPixelsDerivatives[i][baseimg.height - 1][4] = BIG_DERIVATIVE;
      if (i != 0) adjPixelsDerivatives[i][baseimg.height - 1][6] = BIG_DERIVATIVE; //(grayScaleImage[i-1][baseimg.height - 1]   - grayScaleImage[i][baseimg.height - 1]) / 1.0;
      if (i != 0) adjPixelsDerivatives[i][baseimg.height - 1][5] = -BIG_DERIVATIVE;//(grayScaleImage[i-1][baseimg.height - 2] - grayScaleImage[i][baseimg.height - 1]) / sqrt(2);
      if (i != baseimg.width -1) adjPixelsDerivatives[i][baseimg.height - 1][3] = -BIG_DERIVATIVE;// (grayScaleImage[i+1][baseimg.height - 2] - grayScaleImage[i][baseimg.height - 1]) / sqrt(2);
      if (i != baseimg.width -1) adjPixelsDerivatives[i][baseimg.height - 1][2] = BIG_DERIVATIVE; //(grayScaleImage[i+1][baseimg.height - 1]   - grayScaleImage[i][baseimg.height - 1]) / 1.0;
      adjPixelsDerivatives[i][baseimg.height - 1][0] = -BIG_DERIVATIVE;//(grayScaleImage[i][baseimg.height - 2]   - grayScaleImage[i][baseimg.height - 1]) / 1.0;
  }
  
  //go through first and last columns of pixels in image

  for(j = 0; j < baseimg.height; j++)
  {
      //first column
      adjPixelsDerivatives[0][j][5] = BIG_DERIVATIVE;
      adjPixelsDerivatives[0][j][6] = BIG_DERIVATIVE;
      adjPixelsDerivatives[0][j][7] = BIG_DERIVATIVE;
      if (j != 0) adjPixelsDerivatives[0][j][0] = BIG_DERIVATIVE; //(grayScaleImage[0][j-1]   - grayScaleImage[0][j]) / 1.0;
      if (j != 0) adjPixelsDerivatives[0][j][3] = -BIG_DERIVATIVE;//(grayScaleImage[1][j-1] - grayScaleImage[0][j]) / sqrt(2);
      if (j != baseimg.height - 1) adjPixelsDerivatives[0][j][1] = BIG_DERIVATIVE; //(grayScaleImage[0][j+1]   - grayScaleImage[0][j]) / 1.0;
      if (j != baseimg.height - 1) adjPixelsDerivatives[0][j][4] = -BIG_DERIVATIVE;//(grayScaleImage[1][j+1] - grayScaleImage[0][j]) / sqrt(2);
      adjPixelsDerivatives[0][j][2] = -BIG_DERIVATIVE; //(grayScaleImage[1][j]   - grayScaleImage[0][j]) / 1.0;
      
      //last column
      adjPixelsDerivatives[baseimg.width -1][j][3] = BIG_DERIVATIVE; 
      adjPixelsDerivatives[baseimg.width -1][j][2] = BIG_DERIVATIVE; 
      adjPixelsDerivatives[baseimg.width -1][j][4] = BIG_DERIVATIVE; 
      if (j != 0) adjPixelsDerivatives[baseimg.width -1][j][0] = BIG_DERIVATIVE; //(grayScaleImage[baseimg.width -1][j-1]   - grayScaleImage[baseimg.width -1][j]) / 1.0;
      if (j != 0) adjPixelsDerivatives[baseimg.width -1][j][5] = -BIG_DERIVATIVE;//(grayScaleImage[baseimg.width -2][j-1] - grayScaleImage[baseimg.width -1][j]) / sqrt(2);
      if (j != baseimg.height - 1) adjPixelsDerivatives[baseimg.width -1][j][7] = -BIG_DERIVATIVE;//(grayScaleImage[baseimg.width -2][j+1] - grayScaleImage[baseimg.width -1][j]) / sqrt(2);
      if (j != baseimg.height - 1) adjPixelsDerivatives[baseimg.width -1][j][1] = BIG_DERIVATIVE; // (grayScaleImage[baseimg.width -1][j+1]   - grayScaleImage[baseimg.width -1][j]) / 1.0;
      adjPixelsDerivatives[baseimg.width -1][j][6] = -BIG_DERIVATIVE;//(grayScaleImage[baseimg.width -2][j]   - grayScaleImage[baseimg.width -1][j]) / 1.0;
      
  }
    
  //set the gradients for the inner rows and columns
  for (j = 1; j < baseimg.height - 1; j++){
       for (i = 1; i < baseimg.width - 1; i++){
        
          adjPixelsDerivatives[i][j][0] = (grayScaleImage[i][j-1]   - grayScaleImage[i][j]) / 1.0;
          adjPixelsDerivatives[i][j][1] = (grayScaleImage[i][j+1]   - grayScaleImage[i][j]) / 1.0;
          adjPixelsDerivatives[i][j][2] = (grayScaleImage[i+1][j]   - grayScaleImage[i][j]) / 1.0;
          adjPixelsDerivatives[i][j][3] = (grayScaleImage[i+1][j-1] - grayScaleImage[i][j]) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][4] = (grayScaleImage[i+1][j+1] - grayScaleImage[i][j]) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][5] = (grayScaleImage[i-1][j-1] - grayScaleImage[i][j]) / sqrt(2);//corner
          adjPixelsDerivatives[i][j][6] = (grayScaleImage[i-1][j]   - grayScaleImage[i][j]) / 1.0;
          adjPixelsDerivatives[i][j][7] = (grayScaleImage[i-1][j+1] - grayScaleImage[i][j]) / sqrt(2);//corner
    }
  }
}

/*
          if (printpixelgradients) {
              if (i >=200 && i <=204 && j >= 142 && j <= 148) {
                s  += " " + nf(convertToGrayScale(baseimg.get(i, j)), 7);
                s0 +=  " "; if (adjPixelsDerivatives[i][j][0] >= 0) s0 += "+"; s0 += nf(adjPixelsDerivatives[i][j][0], 3,2);
                s1 +=  " "; if (adjPixelsDerivatives[i][j][1] >= 0) s1 += "+"; s1 += nf(adjPixelsDerivatives[i][j][1], 3,2);
                s2 +=  " "; if (adjPixelsDerivatives[i][j][2] >= 0) s2 += "+"; s2 += nf(adjPixelsDerivatives[i][j][2], 3,2);
                s3 +=  " "; if (adjPixelsDerivatives[i][j][3] >= 0) s3 += "+"; s3 += nf(adjPixelsDerivatives[i][j][3], 3,2);
                s4 +=  " "; if (adjPixelsDerivatives[i][j][4] >= 0) s4 += "+"; s4 += nf(adjPixelsDerivatives[i][j][4], 3,2);
                s5 +=  " "; if (adjPixelsDerivatives[i][j][5] >= 0) s5 += "+"; s5 += nf(adjPixelsDerivatives[i][j][5], 3,2);
                s6 +=  " "; if (adjPixelsDerivatives[i][j][6] >= 0) s6 += "+"; s6 += nf(adjPixelsDerivatives[i][j][6], 3,2);
                s7 +=  " "; if (adjPixelsDerivatives[i][j][7] >= 0) s7 += "+"; s7 += nf(adjPixelsDerivatives[i][j][7], 3,2);
    
                if (i== 204){
                  s += "\n"; s0 += "\n"; s1 += "\n"; s2 += "\n"; s3 += "\n"; s4 += "\n"; s5 += "\n"; s6 += "\n"; s7 += "\n";
                }
              }
          }
          if (printpixelgradients) println (s); println (s0); println (s1); println (s2); println (s3); println (s4); println (s5); println (s6); println (s7); 

*/
  //for a pixel location, map the direction of the force vector to a octant, and the octant determines which of the 8 gradients from the pixel will be used
int MapVectorToGradientIndex(PVector vector)
{
     
        /*  Numbering neighboring pixels around a refernce pixel (i,j)
            i-1  i  i+1
           ------------
           | 5 | 0 | 3 | j-1
           ------------
           | 6 |i,j| 2 |  j
           ------------
           | 7 | 1 | 4 | j+1
        */  
 
       int index = -1;
       float theta = vector.heading();
              
       if (theta > -PI/8 && theta <= PI/8 ) index = 2;
       else if (theta > PI/8 && theta <= 3*PI/8 ) index = 3;
       else if (theta > 3*PI/8 && theta <= 5*PI/8) index = 0;
       else if (theta > 5*PI/8 && theta <= 7*PI/8) index = 5;
       else if (theta > 7*PI/8 || theta <= -7*PI/8) index = 6;  //around 180 degrees
       else if (theta > -7*PI/8 && theta <= -5*PI/8)index = 7;
       else if (theta > -5*PI/8 && theta <= -3*PI/8)index = 1;
       else if (theta > -3*PI/8 && theta <= -PI/8)index = 4;
  
       
       //println("vector: (" + vector.x + "," + vector.y + ") Angle = " + theta + " Index = " + index);

       return index; //should not reach here
}
