
class Point 
{
   float x, y;
   PVector randDirection;
   PVector netForce;
   PVector velocity;
   int myindexingloballist; //point's index in global list, temporary variable that is recomputed at start of every iteration to efficiently get the index of point, 
   
   PointSystem parentps; //tracks the parent point system to which this point belongs
   
   Point(float px, float py, PointSystem parent)
   {
      x = px;
      y = py;
      //mass = 1.0;

      parentps = parent;
      
      randDirection = new PVector(0, 0);
      netForce = new PVector(0.0, 0.0);
      velocity = new PVector(0.0, 0.0);
   }
   
   void apply_friction()
   {
      PVector force = PVector.mult(velocity, -coeff_friction);
      netForce.add(force);
   }
   
   void apply_brownianmotion()
   {
      
      PVector BRForce = new PVector(0.0, 0.0); 
     
      int x_index = (int)(this.x - imgTopLeftCorner_X);
      int y_index = (int)this.y;
      
      //random offset vector has magnitude and direction, where magnitude and direction have mean 0, variance sigma
      BRForce.set(randomGaussian(), randomGaussian());
      
      BRForce.mult(f_b[x_index][y_index] * delta[x_index][y_index] * D);
      if (debug) println("BRForce: " + BRForce);
      netForce.add(BRForce);
   }
   
   void apply_transformation()
   {      
      if(Float.isNaN(this.x) || Float.isNaN(this.y))
      {
          println();
          println("apply_transformation: unexpected condition, exiting" ); 
          exit();
      }
            
      velocity.add(PVector.mult(netForce, unit_of_time)); // v = F/m * unit time  ; 

      if(Float.isNaN(netForce.x) || Float.isNaN(netForce.y)) {
         println("netForce is NaN");
         exit();
      }
      
      if (debug) println("netForce: " + netForce.x + " " + netForce.y + " velocity:(" + velocity.x + "," + velocity.y + ")");
      
      
      //translate point and constrain to screen
            
      x += velocity.x;
      y += velocity.y;
      
      x = constrain(x, parentps.top_left_X, parentps.bottom_right_X); //contrain the point within the bounding box of the point system
      y = constrain(y, parentps.top_left_Y, parentps.bottom_right_Y); //contrain the point within the bounding box of the point system

   }

    
}
