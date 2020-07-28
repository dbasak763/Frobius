
class Point 
{
   float x, y;
   float next_x, next_y; // temporarily stores  the next (x,y) where point will move to, used to help step through each iteration
   PVector netForce;
   PVector velocity;
   int myindexingloballist; //point's index in global list, temporary variable that is recomputed at start of every iteration to efficiently get the index of point, 
   
   PointSystem parentps; //tracks the parent point system to which this point belongs to get the bounding box within which point should be constrained
   
   Point(float px, float py, PointSystem parent)
   {
      x = next_x = px;
      y = next_y = py;
      
      //mass = 1.0;

      parentps = parent;
      
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
      
       
      //translate point and constrain to screen
            
      next_x = x + velocity.x;
      next_y = y + velocity.y;
      
      
      if (debug1){
        if (dist(x,y, next_x, next_y) > 200) 
          println("Point [" + myindexingloballist + "]  netForce: (" + netForce.x + " " + netForce.y + "); velocity: (" + velocity.x + "," + velocity.y + ")");
      }
    
      next_x = constrain(next_x, parentps.top_left_X, parentps.bottom_right_X); //contrain the point within the bounding box of the point system
      next_y = constrain(next_y, parentps.top_left_Y, parentps.bottom_right_Y); //contrain the point within the bounding box of the point system

   }

  void printPointDetails(){
   println ("Point [" + myindexingloballist + "] at location ( " + x + " , " + y + ")"); 
  }
    
}
