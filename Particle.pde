
//float emitter_squarewall_len;
int PARTSIZE = 5;

ArrayList<ParticleSystem> systems = new ArrayList<ParticleSystem>();


class Location
{
     float x, y;
     Location(){
        x = 0.0;
        y = 0.0;
     }
     Location(float x, float y){
         this.x = x;
         this.y = y;
     }
     float getLocX(){
         return x; 
     }
     float getLocY(){
         return y; 
     }
     void setLoc(float x, float y){
         this.x = x;
         this.y = y;
     }
     void translateLoc(float delta_x, float delta_y){
         this.x += delta_x;
         this.y += delta_y;
     }
}
     


boolean isWithinSquareBox(Location l, float x1, float y1, float x2, float y2) {

  if((l.x >= x1) && (l.x <= x2) && (l.y >= y1) && (l.y <= y2))
     return true;
  else return false; 
}

Location getLocationInsideSquareBox(float x1, float y1, float x2, float y2){
  float x=-1, y=-1;
  Location l = new Location(x,y); 

  while(!isWithinSquareBox(l, x1, y1, x2, y2)){
    x = random(x1, x2);
    y = random(y1, y2);
    l.setLoc(x,y);
  }
  return l;
}

class Particle {

  PVector velocity;
  PVector net_force;
  float mass = random(5, 10);
  float partLifespan;
  float rebirth_angle;
  float acceleration = 0.0;
  PShape partShape;
  float total_velocity;
  float partSize;
  Location particle_location;//store particle's location with Location variable as particle is a bunch of vertices with different coordinates
  PVector partGravity = new PVector(0,0.1);
  PVector randDirection;
  ParticleSystem parentps;

  Particle(ParticleSystem parentPartSystm) {
    
    parentps = parentPartSystm;
    partSize = PARTSIZE;
    partShape = createShape();
    partShape.setFill(color(random(255), random(255), random(255)));
    
    partShape.beginShape(QUAD);
    partShape.noStroke();
    //part.texture(sprite);
    partShape.normal(0, 0, 1);
    partShape.vertex(-partSize/2, -partSize/2);//, imgTopLeftCorner_X, 0);
    partShape.vertex(+partSize/2, -partSize/2);//, imgTopLeftCorner_X + baseimg.width, 0);
    partShape.vertex(+partSize/2, +partSize/2);//, imgTopLeftCorner_X + baseimg.width, baseimg.height);
    partShape.vertex(-partSize/2, +partSize/2);//, imgTopLeftCorner_X, baseimg.height);
    partShape.endShape();
    
    particle_location = new Location();
        
    rebirth(baseimg.width/2, baseimg.height/2);//problem is here
    partLifespan = random(parentps.MaxPartLifeSpan);
  }

  PShape getShape() {
    return partShape;
  }
  
  void rebirth(float x, float y) {
    //println("x = " + x + " y = " + y);
    rebirth_angle = random(TWO_PI);
    float speed = random(0.5,4);
    
    velocity = new PVector(cos(rebirth_angle), sin(rebirth_angle));//particle is given a random direction
    velocity.mult(speed);
    acceleration = random(max_acceleration);
    
    //note a particle when rebirthed may have acceleration in one unique direction, if there is
    //no brownian motion set, also note that if acceleration checkbox has not been clicked,
    //then acceleration = 0;
    partShape.resetMatrix();
    partShape.translate(x, y);
    particle_location.setLoc(x, y);
    
    //get x,y in base image translated from  x,y in window
    float x_val = x - imgTopLeftCorner_X;
    float y_val = y;
    color pix = baseimg.get((int)x_val, (int)y_val);
    partShape.setFill(pix);
  }
  
  boolean isDead() {
    if (partLifespan < 0 || 
        !isWithinSquareBox(particle_location,
                           parentps.top_left_X, parentps.top_left_Y, 
                           parentps.bottom_right_X, parentps.bottom_right_Y) || 
        !OverImage(particle_location.x, particle_location.y)) {
      partLifespan = parentps.MaxPartLifeSpan;
      return true;
    } else {
     return false;
    } 
  }
  

  public void update() {
    partLifespan -= 1;//update lifespan //<>// //<>//
    
    net_force = new PVector(0, 0);//want to find net force on 
    //particle at certain time, always initialize to null
    
    partGravity = new PVector(0, gravity);//first consider gravity
    net_force.add(partGravity.mult(mass));//mg
    
    //Give particle a random acceleration in random direction(just to be clear)
    //Note brownian motion can only work when particles are given a random acceleration
    
    if(has_brownianmotion)
    {

      float a = random(TWO_PI);
      acceleration = random(max_acceleration);
      randDirection = new PVector(acceleration*cos(a), acceleration * sin(a));
    }
    else 
    {
       randDirection = new PVector(acceleration*cos(rebirth_angle), acceleration*sin(rebirth_angle));
    }
    
    net_force.add(randDirection.mult(mass));

    if(has_attractionrepulsion)
    {
        /*
        for(int i = 0; i < spirals.size(); i++)//for each spiral
        {
            
            Spiral s = spirals.get(i);
            
            for(int j = 0; j < s.points.size(); j++)//get pair of points
            {
                 for(int k = j + 1; k < s.points.size(); k++)
                 {
                     Point p1 = s.points.get(j);
                     Point p2 = s.points.get(k);
                     
                     float sqrdistance = calculateDistBetweenPoints(p1, p2);
                     //if two points are within maxRadius from each other
                     if(sqrdistance <= (max_Radius * max_Radius))
                     {
                         //applyForces(p1, p2);
                     }
                     
                     //for()
                 }
            }
        }
        */
    }
    
    //calculate friction force on particle, -kv, note that v is velocity at beginning of click
    //and velocity has not been changed yet after considering the forces gravity and randomDirection
    //so what we are doing is fine
    
    if(coeff_friction > 0.0) net_force.add(velocity.mult(coeff_friction*-1));//Compute friction, -kv
    
    PVector net_acceleration = net_force.mult(1/mass);
    velocity.add(net_acceleration.mult(unit_of_time));//Now we finally update velocity vector based on net_force on particle at the time
    //magnitude of new velocity vector changes, this becomes our new initial velocity
    
    partShape.setTint(color(255, partLifespan));
    float x_val = velocity.x * unit_of_time;
    float y_val = velocity.y * unit_of_time;
    particle_location.translateLoc(x_val, y_val);
    partShape.translate(x_val, y_val);    
  }//updates particle
}

public class ParticleSystem {
  ArrayList<Particle> particles;
  int num_of_particles;
  PShape particleShape;
  float top_left_X, top_left_Y, bottom_right_X, bottom_right_Y;
  int MaxPartLifeSpan = 10;

  ParticleSystem(int n, int lifespan, float topLeftX, float topLeftY, float botRightX, float botRightY) {
   
    num_of_particles = n;
    MaxPartLifeSpan = lifespan;
    
    //give Particlesystem an origin
    top_left_X = topLeftX;
    top_left_Y = topLeftY;
    bottom_right_X = botRightX;
    bottom_right_Y = botRightY;
        
    particles = new ArrayList<Particle>();
    particleShape = createShape(PShape.GROUP);
    
    println("In ps constructor n = " + num_of_particles); //<>//
    
    for (int i = 0; i < num_of_particles; i++) {
      Particle p = new Particle(this);
      particles.add(p);
      particleShape.addChild(p.getShape());
    }
  }
  void change_num_of_particles(int num){
     
    num_of_particles = num;
    //delete the existing list of particles and create a new list with the new number of partciles
     particles.clear();
     
     for (int i = 0; i < num_of_particles; i++) {
        Particle p = new Particle(this);
        particles.add(p);
        particleShape.addChild(p.getShape());
      }
  }
  
  void updateLifeSpan(int updatedLifeSpan){
    MaxPartLifeSpan = updatedLifeSpan;
  }
  
  //copied code
  void update() {
    for (Particle p : particles) {
      p.update();
    }
  }
  
  void setEmitter() {

    for (Particle p : particles) {
      if (p.isDead()) { //<>//
        //instead of respawning at some random location on the image screen, 
        // spawn the particle within user specified box wall region
        Location l = getLocationInsideSquareBox(top_left_X, top_left_Y, bottom_right_X, bottom_right_Y);
        p.rebirth(l.x, l.y);
      }
    }
  }

  void display() {
    if (display_points){
      shape(particleShape);
    }
  }

}
