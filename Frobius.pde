
int lifespan;
int numParticles = 0;
float unit_of_time = 1.0;
boolean debug = false;
boolean debug1 = true;

boolean showImage = true;
boolean createParticleSystem = false; // create Particle System
boolean createPointSystem = true; // create Spiral Path
boolean showParticleSystem = true; // show ParticleSystems
boolean showPointSystem = true; // show SpiralPaths

// the 2 variables below allow user to get into a step mode
// and then do a bang to move to next step.
// and see how the points are going to move at the end of the iteration.
boolean stepmode = false; // allows user to step 
boolean stepthrough = false;


//force related variabales
float   max_acceleration = 0.0; // a particle/point picks a random acceleration less than this
boolean has_brownianmotion = false;
float   coeff_friction = 0.25;//coefficient of friction

int n_min = 2;

boolean has_attractionrepulsion = false;
boolean has_anisotropy = false;
float   D;//controlled by user, D is the average distance between two points
float   R1 = 0.0; //distance outside which points dont influence each other
float   R0 = 0.0;  //distance inside which points repel each other

float kmin = 0.2;
float kmax = 1.2;

boolean has_fairing = false;

float F_A = 1.0;  // for now this value is used as scaling for attraction for all points
float F_B = 0.2;  // for now this value is used as scaling for brownian for all points
float F_F = 0.3;  // for now this value is used as scaling for fairing for all points

float[][][] adjPixelsDerivatives;
float[][]   f_a, f_b, f_f;  // scaling functions for AR, Brownian, and Fairing, respectively, for now F_A, F_B, F_B is used for all points
float[][]   delta;
float[][]   grayScaleImage;


float gravity;

void draw() {
  background(220);
  strokeWeight(4);
  
  drawGUIBackground();
  
  if (baseimg != null)           // go in if baseimg exists
  {
    
      if(showImage) 
      {
          image(baseimg, imgTopLeftCorner_X, 0);  
          //filter(GRAY); 
      }
       
      if(showParticleSystem)
      {
         for(ParticleSystem ps: systems)
         {
           if (ps != null){
              ps.update();
              ps.display();
              ps.setEmitter();
            }
         } 
      }
      
      
      stroke(0);
      strokeWeight(1);
      stroke(40);
      
      int tot_points = 0;
      if(showPointSystem)
      {
           for(PointSystem ps: spirals)
           {
             if (ps != null){
                 if (!stepmode || stepthrough) { //  go in if stepmode is not on, or stepmode is on and stepthrough is set
                    ps.getReadyForNextIteration();
                    ps.computeNetForceandNewPositionofPoints();
                 }
               ps.display();
               tot_points += ps.points.size();
             }        
           }
           if (stepmode) stepthrough = false;  // if step mode set setpthrough to flase, so user has to bang "step" to set this varible to true;
      }
      
      myTextlabelB.setText("Point Count:  " + tot_points); 
      myTextlabelE.setText("Delta:  " +  delta_min_for_GUI_only + " (min),    " + delta_max_for_GUI_only + " (max)");
      myTextlabelF.setText("fa :  " +  F_A + ",   f_b :  " + F_B + ",   f_f : " + F_F);
      myTextlabelG.setText("d for resampling:  " +  nf(D*kmin*delta_min_for_GUI_only,0,1) + " (min),\n                                 " + nf(D*kmax*delta_max_for_GUI_only,0,1) + " (max)");

      
   }
   else {   // no base image
    textAlign(CENTER);
    text("First load an image. Then you can click, drag, release to create a bounding box inside image. \n Depending on whether you selected an emitter or a Point system, one will be generated inside the bounding box.\n You can repeat to create multiple systems and mix and match.\n You can also just click anywhere inside the image to create a system covering the full image.", GUIWidth + (width-GUIWidth)/2, height/2);

  }
  
  myTextlabelA.setText("FrameCount: " + frameCount);
  myTextlabelC.setText("R0:  " + (int) R0 + ",     R1:  " + (int) R1);
  myTextlabelD.setText("K1:  " +  (2.5 * (float) cp5.getController("AttractRepelK0").getValue()) );

}





    
    
  
  
