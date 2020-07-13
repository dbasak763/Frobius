ArrayList<Point> points;

class Point 
{
   float x, y;
   float mass;
   PVector randDirection;
   PVector netForce;
   PVector velocity;
   int Max_Rebirth_Distance_X, Max_Rebirth_Distance_Y;
   
   PointSystem parentps; //tracks the parent point system to which this point belongs
   
   Point(float px, float py, PointSystem parent)
   {
      x = px;
      y = py;
      mass = 1.0;

      parentps = parent;
      
      Max_Rebirth_Distance_X = 20;//(int)(parentps.bottom_right_X - parentps.top_left_X);
      Max_Rebirth_Distance_Y = 20;//(int)(parentps.bottom_right_Y - parentps.top_left_Y);
      
      randDirection = new PVector(0, 0);
      netForce = new PVector(0.0, 0.0);
      velocity = new PVector(0.0, 0.0);
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
   
   void apply_transformation()
   {
      int x_index = (int)(this.x - imgTopLeftCorner_X);
      int y_index = (int)this.y;
      
      if (x_index < 0 || x_index >= baseimg.width || y_index < 0 || y_index >= baseimg.height || Float.isNaN(this.x) || Float.isNaN(this.y)) {
          println ("apply_transformation: unexpected condition, exiting" ); 
          exit();
      }
      
      float inertiaOfPoint = (float) inertia[x_index][y_index]; // get reference relative to base image
      
      if (inertiaOfPoint == 0.0) {
        println("Inertia of Point should not be zero. x_index:" + x_index + " y_index:" + y_index); 
        exit();
      }
      //print("apply_transformation  enter velocity:(" + velocity.x + "," + velocity.y + ")");
      velocity.add(PVector.mult(netForce, unit_of_time/inertiaOfPoint)); // v = F/m * unit time  ; instead of fixed mass, use an inertia of point based on base pixel color
      //println(" exit velocity:(" + velocity.x + "," + velocity.y + ")" + "Inertia Factor =" + inertiaOfPoint);
      
      
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

      // also reset the netforce on a point for next iteration
      netForce.set(0.0,0.0);
      //velocity.set(0.0,0.0);
   }
   
   //adjust the AR force based on gradient of image pixel at point location p1 and  accumulate force in point p1
   void AdjustandAddARForce(PVector ARforce){
     
         if(debug) print ("AdjustandAddARForce In Netforce:[" + netForce.x + "," + netForce.y + "]"); 
 
         if (ARforce.magSq() > 0) {
           int index = MapVectorToGradientIndex(ARforce);
                  
           float derivative;
         
           derivative = adjPixelsDerivatives[(int)(this.x - imgTopLeftCorner_X)][(int)this.y][index]; //get reference relative to base image
          
             
           //if derivative > 0,  scaleFactor < 1, else scaleFactor > 1, f(x) = (x - 1) ^ (1/3)
        
           float scaleFactor = ((float)Math.cbrt(derivative - 1) + 2.0)/10.0;
           
           // Netforce = ARforce + ARforce*scalefactor
           netForce.add(ARforce);
           netForce.add(PVector.mult(ARforce,scaleFactor));
           
           if (debug){
             print (" ARforce:[" + ARforce.x + "," + ARforce.y + "]" + "scaleFactor: " + scaleFactor + " Out Netforce:[" + netForce.x + "," + netForce.y + "]"); 
           }
         }

         if (debug) println();
    }
    
}


    
  
