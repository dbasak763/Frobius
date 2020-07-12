ArrayList<Point> points;

class Point 
{
   float x, y;
   float mass;
   PVector randDirection;
   PVector netForce;
   PVector velocity;
//   int Max_Rebirth_Distance_X, Max_Rebirth_Distance_Y;
   
   PointSystem parentps; //tracks the parent point system to which this point belongs
   
   Point(float px, float py, PointSystem parent)
   {
      x = px;
      y = py;
      mass = 1.0;

      parentps = parent;
      
      //Max_Rebirth_Distance_X = (int)(parentps.bottom_right_X - parentps.top_left_X);
      //Max_Rebirth_Distance_Y = (int)(parentps.bottom_right_Y - parentps.top_left_Y);
      
      randDirection = new PVector(0, 0);
      netForce = new PVector(0, 0);
      velocity = new PVector(0, 0);
   }

   void apply_friction()
   {
      PVector force = PVector.mult(velocity, -coeff_friction);
      netForce.add(force);
   }
   //not localized
   void apply_ARforces()
   {
        
   }
   
   void apply_brownianmotion()
   {
      float a = random(TWO_PI);
      float b = random(max_acceleration);//b is magnitude of acceleration
      
      PVector force = new PVector(b*cos(a), b*sin(a));
      netForce.add(force);
   }
   
   //TO FIX
   void apply_constrain()
   {
      if(x<=5) netForce.add(1, 0);
      else if(x>=495) netForce.add(-1, 0);
      if(y<=5) netForce.add(0, 1);
      else if(y>=495) netForce.add(0, -1);
   }
   
   void apply_transformation()
   {
      
      velocity.add(PVector.mult(netForce, unit_of_time/mass)); // v = F/m * unit time

      //translate point and constrain to screen
      
      x += velocity.x;
      y += velocity.y;

      x = constrain(x, parentps.top_left_X, parentps.bottom_right_X); //contrain the point within the bounding box of the point system
      y = constrain(y, parentps.top_left_Y, parentps.bottom_right_Y); //contrain the point within the bounding box of the point system
      
      
/*      //move point away from boundaries to prevent clustering, doesn't work properly
      if(x == parentps.top_left_X)
      {
          x += random(0, Max_Rebirth_Distance_X);
      }
      else if(x == parentps.bottom_right_X)
      {
          x -= random(0, Max_Rebirth_Distance_X);
      }
      
      if(y == parentps.top_left_Y)
      {
         y += random(0, Max_Rebirth_Distance_Y);
      }
      else if(y == parentps.bottom_right_Y)
      {
         y -= random(0, Max_Rebirth_Distance_Y); 
      }
 */

   }
   
   //adjust the AR force based on gradient of image pixel at point location p1 and  accumulate force in point p1
   void AdjustandAddARForce(PVector ARforce){
         int index = MapVectorToGradientIndex(ARforce);
         
         
         float derivative = adjPixelsDerivatives[(int)(this.x - imgTopLeftCorner_X)][(int)this.y][index];
        
           
         //if derivative > 0, so scaleFactor < 1
         //else scaleFactor > 1, f(x) = (x - 1) ^ (1/3)
      
         float scaleFactor = (float)Math.cbrt(derivative - 1) + 2.0;
         
         //println("scaleFactor = " + scaleFactor);
    
         netForce.add(PVector.mult(ARforce,scaleFactor));
    }
                        
   //for a pixel location, map the direction of the force vector to a octant, and the octant determines which of the 8 gradients from the pixel will be used
   int MapVectorToGradientIndex(PVector force)
   {
       //println("force vector = < " + force.x + ", " + force.y + ">");
       float theta = PVector.angleBetween(new PVector(0, 1), force); // get the angle of force vector wrt the horizontal
       //println("theta = " + theta + ", return_value = " + (int)(theta / (PI / 4)));
       return (int)(theta / (PI / 4));//returns number from 0-7
             
   }
    
}


    
  
