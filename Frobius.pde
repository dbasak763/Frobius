
int lifespan;
int numParticles = 0;
float unit_of_time = 1.0;
boolean debug = false;

boolean showImage = true;
boolean createParticleSystem = false; // create Particle System
boolean createPointSystem = true; // create Spiral Path
boolean showParticleSystem = true; // show ParticleSystems
boolean showPointSystem = true; // show SpiralPaths
boolean showGridTiles = true;// show gridTiles

//force related variabales
float   max_acceleration = 0.0; // a particle/point picks a random acceleration less than this
boolean has_brownianmotion = false;
float   coeff_friction = 0.25;//coefficient of friction


boolean has_attractionrepulsion = false;
float   D_attraction = 0.0; //distance outside which points dont influence each other
float   D_repulsion = 0.0;  //distance inside which points repel each other, set to 25% of attract
float[][][] adjPixelsDerivatives;
int[][]   inertia;
int[][]   grayScaleImage;
int inertiaFactor = 10;  //must be 1 or higher


float gravity;


void draw() {
  background(220);
  strokeWeight(4);
  
  drawGUIBackground();
  
  if (baseimg != null){
    
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

      if(showPointSystem)
      {
         for(PointSystem ps: spirals)
         {
           noFill();
           if (ps != null){
              ps.display();
              ps.computeNetForceandNewPositionofPoints();
            }        
         }
      }
   }
   else {   // no base image
    textAlign(CENTER);
    text("First load an image. Then you can click, drag, release to create a bounding box inside image. \n Depending on whether you selected an emitter or a Point system, one will be generated inside the bounding box.\n You can repeat to create multiple systems and mix and match.\n You can also just click anywhere inside the image to create a system covering the full image.", GUIWidth + (width-GUIWidth)/2, height/2);

  }
    
}





    
    
  
  
